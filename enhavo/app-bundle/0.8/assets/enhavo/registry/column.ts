import RegistryPackage from "@enhavo/core/RegistryPackage";
import ApplicationInterface from "@enhavo/app/ApplicationInterface";
import AppColumnRegistryPackage from "@enhavo/app/Grid/Column/ColumnRegistryPackage";

export default class ColumnRegistryPackage extends RegistryPackage
{
    constructor(application: ApplicationInterface) {
        super();
        this.registerPackage(new AppColumnRegistryPackage(application));
    }
}