<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class Example extends Model
{
    protected $connection = 'oracle';
    protected $table    = 'ZTE.TF_RNC_CELLRABHOLDINGTIME';
    protected $fillable = ['RNCID','CELDA','SECTOR'];
}
