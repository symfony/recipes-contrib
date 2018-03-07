<?php

namespace App\Entity\Eav;

use MsgPhp\Eav\AttributeValueIdInterface;
use MsgPhp\Eav\Entity\AttributeValue as BaseAttributeValue;

/**
 * @final
 */
class AttributeValue extends BaseAttributeValue
{
    private $id;

    public function __construct(AttributeValueIdInterface $id, Attribute $attribute, $value)
    {
        parent::__construct($attribute, $value);

        $this->id = $id;
    }

    public function getId(): AttributeValueIdInterface
    {
        return $this->id;
    }
}
