<?php

namespace App\Entity\EasyFaq;

use Adeliom\EasyFaqBundle\Entity\EntryEntity as BaseEntryEntity;
use Doctrine\ORM\Mapping as ORM;

/**
 * @ORM\Entity(repositoryClass="App\Repository\EasyFaq\EntryRepository")
 * @ORM\HasLifecycleCallbacks()
 * @ORM\Table(
 *     name="easy_faq__entry",
 *     indexes={
 *      @ORM\Index(name="easy_faq_indexes", columns={"state"})
 *     }
 * )
 */
class Entry extends BaseEntryEntity
{

}
