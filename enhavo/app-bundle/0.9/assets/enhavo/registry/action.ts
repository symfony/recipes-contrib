import RegistryPackage from "@enhavo/core/RegistryPackage";
import ApplicationInterface from "@enhavo/app/ApplicationInterface";
import AppActionRegistryPackage from "@enhavo/app/Action/ActionRegistryPackage";

export default class ActionRegistryPackage extends RegistryPackage
{
    constructor(application: ApplicationInterface) {
        super();
        this.registerPackage(new AppActionRegistryPackage(application));
    }
}