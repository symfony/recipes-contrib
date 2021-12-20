<?php

namespace App\Controller\Admin\EasyShop\Marketing;

use Adeliom\EasyShopBundle\Admin\Marketing\PromotionCrudController as BasePromotionCrudController;
use App\Entity\EasyShop\Promotion\Promotion;

class PromotionCrudController extends BasePromotionCrudController
{
    public static function getEntityFqcn(): string
    {
        return Promotion::class;
    }
}
