import { DOMWidgetView } from "@jupyter-widgets/base";
import { timeout } from "d3";
import * as Events from "./BayesEvents";
import BayesViewerModel from "./BayesViewerModel";
import BayesNetInteractor from "./components/BayesNetVisualizer.vue";
import { IObservation, ObservationManager} from "./Observation";

import * as Analytics from "../Analytics";
import {IBayesGraphNode} from "../Graph";
import { d3ForceLayout, GraphLayout, relativeLayout } from "../GraphLayout";
import * as labelDict from "../labelDictionary";
import * as StepEvents from "../StepEvents";

export default class BayesViewer extends DOMWidgetView {
  public model: BayesViewerModel;
  private vue: any;
  private manager: ObservationManager;

  public initialize(opts: any) {
    super.initialize(opts);
    this.manager = new ObservationManager();
    this.manager.reset();

    // Receive message from backend
    this.listenTo(this.model, "view:msg", (event: Events.Events) => {
      switch (event.action) {
        case "observe":
          this.manager.add(event.name, event.value);
          break;
        case "query":
          this.parseQueryResult(event);
          break;
      }
    });
  }

  public render() {
    timeout(() => {
      this.vue = new BayesNetInteractor({
        data: {
          graph: this.model.graph,
          output: null,
          /** Layout object that controls where nodes are drawn. */
          layout: new GraphLayout(d3ForceLayout(), relativeLayout()),
          textSize: this.model.textSize,
          detailLevel: this.model.detailLevel,
          legendText: labelDict.bayesLabelText,
          legendColor: labelDict.bayesLabelColor,
          isQuerying: true
        }
      }).$mount(this.el);

      this.vue.$on(StepEvents.PRINT_POSITIONS, () => {
        this.send({
          event: StepEvents.PRINT_POSITIONS,
          nodes: this.vue.graph.nodes
        });
      });

      this.vue.$on("click:observe-node", (node: IBayesGraphNode) => {
        Analytics.trackEvent("Bayes Visualizer", "Observe Node");
        this.chooseObservation(node);
      });

      this.vue.$on("click:query-node", (node: IBayesGraphNode) => {
        Analytics.trackEvent("Bayes Visualizer", "Query Node");

        const dumpData: IObservation[] = this.manager.dump();

        this.send({
          event: "node:query",
          name: node.name,
          evidences: dumpData.map((n: IObservation) => {
            return {"name": n.name, "value": n.value};
          })});
      });

      this.vue.$on('reset', () => {
        this.manager.reset();
        this.model.graph.nodes.map((variableNode: IBayesGraphNode) => {
          variableNode.falseProb = undefined;
          variableNode.trueProb = undefined;
          this.vue.$set(variableNode.styles, "strokeWidth", 0);
        });
      });

      if (!this.model.previouslyRendered) {
        this.send({ event: "initial_render" });
      }
    });
  }

  private parseQueryResult(event: Events.IBayesQueryEvent) {
    const nodes =  this.model.graph.nodes.filter(node => node.name === event.name);
    if (nodes.length === 0) {
      return;
    } else {
      const variableNode = nodes[0] as IBayesGraphNode;
      variableNode.falseProb = event.falseProb;
      variableNode.trueProb = event.trueProb;
      this.vue.$set(variableNode.styles, "strokeWidth", 2);
    }
  }

  private chooseObservation(node: IBayesGraphNode) {
    let value: null | string | boolean = window.prompt(
      "Choose only one observation",
      node.domain.join(", ")
    );

    if (value !== null && !value.includes(', ')) {
      if (value === "true") { value = true; }
      else if (value === "false") { value = false; }
      this.manager.add(node.name, value)
    };
  }
}
