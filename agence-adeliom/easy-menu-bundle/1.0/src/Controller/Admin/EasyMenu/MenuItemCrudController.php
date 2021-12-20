<?php

namespace App\Controller\Admin\EasyMenu;

use Adeliom\EasyCommonBundle\Enum\ThreeStateStatusEnum;
use Adeliom\EasyMenuBundle\Controller\MenuItemCrudController as BaseMenuItemCrudController;
use App\Entity\EasyMenu\MenuItem;
use EasyCorp\Bundle\EasyAdminBundle\Config\Action;
use EasyCorp\Bundle\EasyAdminBundle\Config\Actions;
use EasyCorp\Bundle\EasyAdminBundle\Config\Crud;
use EasyCorp\Bundle\EasyAdminBundle\Config\Filters;
use EasyCorp\Bundle\EasyAdminBundle\Filter\ChoiceFilter;

class MenuItemCrudController extends BaseMenuItemCrudController
{

    public static function getEntityFqcn(): string
    {
        return MenuItem::class;
    }

    public function configureActions(Actions $actions): Actions
    {
        $actions = parent::configureActions($actions);
        return $actions
            ->add(Crud::PAGE_INDEX, Action::DETAIL)
            ;
    }

    public function configureFilters(Filters $filters): Filters
    {
        $filters->add(ChoiceFilter::new("state","Status")->setChoices(ThreeStateStatusEnum::toArray()));

        return $filters;
    }

}
