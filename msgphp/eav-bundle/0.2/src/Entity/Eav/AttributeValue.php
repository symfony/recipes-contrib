<?php

namespace App\Entity\Eav;

use Doctrine\ORM\Mapping as ORM;
use MsgPhp\Eav\AttributeValueIdInterface;
use MsgPhp\Eav\Entity\AttributeValue as BaseAttributeValue;

/**
 * @ORM\Entity()
 */
class AttributeValue extends BaseAttributeValue
{
    /** @ORM\Id() @ORM\GeneratedValue() @ORM\Column(type="msgphp_attribute_value_id", length=191) */
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
