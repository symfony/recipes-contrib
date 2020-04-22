import RegistryPackage from "@enhavo/core/RegistryPackage";
import ApplicationInterface from "@enhavo/app/ApplicationInterface";
import AppBatchRegistryPackage from "@enhavo/app/Grid/Batch/BatchRegistryPackage";

export default class BatchRegistryPackage extends RegistryPackage
{
    constructor(application: ApplicationInterface) {
        super();
        this.registerPackage(new AppBatchRegistryPackage(application));
    }
}