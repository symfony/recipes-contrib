<?php

namespace App\Entity;

use Doctrine\ORM\Mapping as ORM;
use MsgPhp\Eav\Attribute as BaseAttribute;
use MsgPhp\Eav\AttributeId;

/**
 * @ORM\Entity()
 */
class Attribute extends BaseAttribute
{
    /** @ORM\Id() @ORM\GeneratedValue() @ORM\Column(type="msgphp_attribute_id", length=191) */
    private $id;

    public function __construct(AttributeId $id)
    {
        $this->id = $id;
    }

    public function getId(): AttributeId
    {
        return $this->id;
    }
}
