<?php

namespace App\Document;

class Config
{
    /**
     * 标题
     *
     * @return string
     */
    public static function getTitle()
    {
        return '演示';
    }

    /**
     * 出版商
     *
     * @return string
     */
    public static function getPublishing()
    {
        return '';
    }

    /**
     * 说明
     *
     * @return string
     */
    public static function getExplain()
    {
        return '';
    }

    /**
     * 注意
     *
     * @return string
     */
    public static function getNote()
    {
        return '';
    }

    /**
     * 附录
     *
     * @return string
     */
    public static function getAppendix()
    {
        return '';
    }

    /**
     * 主机
     *
     * @return mixed
     */
    public static function getHost()
    {
        return $_ENV['DOC_HOST'];
    }
}
