import Application from "@enhavo/app/Index/IndexApplication";
import ActionRegistryPackage from "./registry/action";
import ModalRegistryPackage from "./registry/modal";
import BatchRegistryPackage from "./registry/batch";
import ColumnRegistryPackage from "./registry/column";
import FilterRegistryPackage from "./registry/filter";
import '@enhavo/app/assets/styles/base.scss'
import '@enhavo/form/assets/styles/form.scss'

Application.getActionRegistry().registerPackage(new ActionRegistryPackage(Application));
Application.getFilterRegistry().registerPackage(new FilterRegistryPackage(Application));
Application.getModalRegistry().registerPackage(new ModalRegistryPackage(Application));
Application.getBatchRegistry().registerPackage(new BatchRegistryPackage(Application));
Application.getColumnRegistry().registerPackage(new ColumnRegistryPackage(Application));
Application.getGrid().load();
Application.getVueLoader().load(() => import("@enhavo/app/Index/Components/IndexComponent.vue"));
