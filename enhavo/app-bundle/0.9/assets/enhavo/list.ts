import Application from "@enhavo/app/List/ListApplication";
import ActionRegistryPackage from "./registry/action";
import ModalRegistryPackage from "./registry/modal";
import ColumnRegistryPackage from "./registry/column";

Application.getActionRegistry().registerPackage(new ActionRegistryPackage(Application));
Application.getModalRegistry().registerPackage(new ModalRegistryPackage(Application));
Application.getColumnRegistry().registerPackage(new ColumnRegistryPackage(Application));
Application.getList().load();
Application.getVueLoader().load(() => import("@enhavo/app/List/Components/ListApplicationComponent.vue"));
