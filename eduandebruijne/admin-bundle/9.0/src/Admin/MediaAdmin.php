<?php

declare(strict_types=1);

namespace App\Admin;

use App\Entity\Media;
use EDB\AdminBundle\Admin\AbstractMediaAdmin;

class MediaAdmin extends AbstractMediaAdmin
{
    public function getEntityClass(): string
    {
        return Media::class;
    }
}
