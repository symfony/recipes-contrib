<?php

namespace App\Controller\Admin\EasyShop\Marketing;

use App\Entity\EasyShop\Product\ProductReview;
use Adeliom\EasyShopBundle\Admin\Marketing\ReviewCrudController as BaseReviewCrudController;

class ReviewCrudController extends BaseReviewCrudController
{
    public static function getEntityFqcn(): string
    {
        return ProductReview::class;
    }
}
