import Application from "@enhavo/app/Main/MainApplication";
import ViewRegistryPackage from "./registry/view";
import MenuRegistryPackage from "./registry/menu";
import WidgetRegistryPackage from "./registry/widget";

Application.getViewRegistry().registerPackage(new ViewRegistryPackage(Application));
Application.getMenuRegistry().registerPackage(new MenuRegistryPackage(Application));
Application.getWidgetRegistry().registerPackage(new WidgetRegistryPackage(Application));
Application.getVueLoader().load(() => import("@enhavo/app/Main/Components/MainComponent.vue"));