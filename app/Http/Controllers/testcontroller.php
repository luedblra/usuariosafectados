<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class testcontroller extends Controller
{
    public function index(){
        /*$all = DB::connection('oracle')->select("select RNCID RNC, SUBSTR(OBJECTID, 0, LENGTH(OBJECTID)-1) CELDA, SUBSTR(OBJECTID,-1) SECTOR
FROM ZTE.TF_RNC_CELLRABHOLDINGTIME
 WHERE DIA = TO_DATE('01/01/2019','DD/MM/YYYY')
");*/


        $all = DB::connection('oracle')->select("select RNCID RNC, SUBSTR(OBJECTID, 0, LENGTH(OBJECTID)-1) CELDA, SUBSTR(OBJECTID,-1) SECTOR
FROM ZTE.TF_RNC_CELLRABHOLDINGTIME
WHERE DIA BETWEEN  TO_DATE('01/01/2019','DD/MM/YYYY') AND  TO_DATE('02/01/2019','DD/MM/YYYY')   
     AND HORA BETWEEN '8' AND '12'");


        dd($all);
    }
}
