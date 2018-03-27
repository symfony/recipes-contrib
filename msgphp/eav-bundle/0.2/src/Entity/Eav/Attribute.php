<?php

namespace App\Entity\Eav;

use Doctrine\ORM\Mapping as ORM;
use MsgPhp\Eav\AttributeIdInterface;
use MsgPhp\Eav\Entity\Attribute as BaseAttribute;

/**
 * @ORM\Entity()
 */
class Attribute extends BaseAttribute
{
    /** @ORM\Id @ORM\Column(type="msgphp_attribute_id") */
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
