<?php

namespace App\Entity\Eav;

use MsgPhp\Eav\AttributeIdInterface;
use MsgPhp\Eav\Entity\Attribute as BaseAttribute;

/**
 * @final
 */
class Attribute extends BaseAttribute
{
    private $id;

    public function __construct(AttributeIdInterface $id)
    {
        $this->id = $id;
    }

    public function getId(): AttributeIdInterface
    {
        return $this->id;
    }
}
