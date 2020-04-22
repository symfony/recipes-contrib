import RegistryPackage from "@enhavo/core/RegistryPackage";
import ApplicationInterface from "@enhavo/app/ApplicationInterface";
import AppWidgetRegistryPackage from "@enhavo/app/Toolbar/Widget/WidgetRegistryPackage";

export default class ViewRegistryPackage extends RegistryPackage
{
    constructor(application: ApplicationInterface) {
        super();
        this.registerPackage(new AppWidgetRegistryPackage(application));
    }
}