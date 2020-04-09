<?php

namespace App\Entity;

use ApiPlatform\Core\Annotation\ApiResource;
use Doctrine\ORM\Mapping as ORM;
use Silverback\ApiComponentBundle\Entity\Core\AbstractComponent;
use Silverback\ApiComponentBundle\Entity\Utility\FileInterface;
use Silverback\ApiComponentBundle\Entity\Utility\FileTrait;
use Symfony\Component\Validator\Constraints as Assert;

/**
 * @author Daniel West <daniel@silverback.is>
 * @ApiResource()
 * @ORM\Entity
 */
class GreetingSampleComponent extends AbstractComponent implements FileInterface
{
    use FileTrait;

    /**
     * @var string a greeting name
     *
     * @ORM\Column
     * @Assert\NotBlank
     */
    public string $name = '';
}
