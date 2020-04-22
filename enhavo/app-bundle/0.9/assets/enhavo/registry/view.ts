import RegistryPackage from "@enhavo/core/RegistryPackage";
import ApplicationInterface from "@enhavo/app/ApplicationInterface";
import AppViewRegistryPackage from "@enhavo/app/ViewStack/ViewRegistryPackage";

export default class ViewRegistryPackage extends RegistryPackage
{
    constructor(application: ApplicationInterface) {
        super();
        this.registerPackage(new AppViewRegistryPackage(application));
    }
}