<?php
/**Esta classe gere as operações realizadas sobre uma base de dados de uma
Loja virtual.*/

class BDMusisys {
  /**Variável da classe que permite guardar a ligação à base de dados.*/
  var $conn;

  /**Função para ligar à BD da Loja
   @return Um valor indicando qual o resultado da ligação à base de dados.*/
   function ligarBD() {
      $this->conn = mysqli_connect("localhost", "root", "", "musisys");
	  if(!$this->conn){
		return -1;
	  }
	}
 
 /**Executa um determinado comando SQL, retornando o seu resultado.  
 @param sql_command Comando SQL a ser executado pela função
 @return O resultado do comando SQL.*/
  function executarSQL($sql_command) {
    $resultado = mysqli_query( $this->conn, $sql_command);
    return $resultado;
 }
 
 /**Fecha a ligação à base de dados*/
 function fecharBD() {
    mysqli_close($this->conn);
 }

}

class EdicaoFestival extends BDMusisys {
    
    var $db_musisys;
    
    function EdicaoFestival(){
        $this->db_musisys = new BDMusisys;
        $this->db_musisys->ligarBD();
    }
    
    function novaEdicao($nome, $localidade, $local, $data_inicio,$data_fim, $lotacao,$num_palcos){
        $sql = "CALL P2('$nome', '$localidade', '$local', '$data_inicio','$data_fim', $lotacao,$num_palcos)";
        $this->db_musisys->executarSQL($sql);
    }
    
    function listarEdicoesFuturas(){
        $result_set = $this->db_musisys->executarSQL("SELECT * FROM edicao WHERE data_inicio > CURDATE()");
        $tuplos = mysqli_num_rows($result_set); 
        if ($tuplos==0) {
            echo "Nenhuma Edição futura registada<br>";
        }else{
            echo "<TABLE BORDER=1 style='color: whitesmoke;'>
                <TR>
                <TH style='width:150px; text-align:center;'>Número</TH>
                <TH style='width:150px; text-align:center;'>Nome</TH>
                <TH style='width:150px; text-align:center;'>Localidade</TH>
                <TH style='width:150px; text-align:center;'>Local</TH>
                <TH style='width:150px; text-align:center;'>Data Inicio</TH>
                <TH style='width:150px; text-align:center;'>Data Fim</TH>
                <TH style='width:150px; text-align:center;'>Lotação</TH>
                <TH style='width:150px; text-align:center;'></TH>
                </TR>";
           for($registo=0; $registo<$tuplos; $registo++) {
                $row = mysqli_fetch_assoc($result_set);
               echo "<TABLE BORDER=1 style='color: whitesmoke;'>
                <TR>
                <TD style='width:150px;'><center>$row[numero]</center></TD>
                <TD style='width:150px;'><center>$row[nome]</center></TD>
                <TD style='width:150px;'><center>$row[localidade]</center></TD>
                <TD style='width:150px;'><center>$row[local]</center></TD>
                <TD style='width:150px;'><center>$row[data_inicio]</center></TD>
                <TD style='width:150px;'><center>$row[data_fim]</center></TD>
                <TD style='width:150px;'><center>$row[lotacao]</center></TD>
                
                 <TD style='width:150px;'><form action=\"listar_artistas.php\" method=post>
                <input type=hidden name=codigo value=$row[numero]>
                <input type=submit style='width:150px;' value=\"Listar Artistas\"></form></TD>
                </TR> ";
            }
           echo "</TABLE>";
        }
    }
    
    function fecharBDEdicao() {
        $this->db_musisys->fecharBD();
    }
  
}

class ParticipantesFestival extends BDMusisys {
    
    var $db_musisys;
    
    function ParticipantesFestival(){
        $this->db_musisys = new BDMusisys;
        $this->db_musisys->ligarBD();
    }
    
    function procurarParticipante($codigo) {
        if(empty($codigo)){
           echo "Nenhum dado inserido <br>";
           return;
        }
        $result_set = $this->db_musisys->executarSQL("SELECT * FROM participante WHERE codigo = $codigo");
        if (mysqli_num_rows($result_set)==0) {
            echo "Participante não encontrado <br>";
        }else{
            $row = mysqli_fetch_assoc($result_set);
            if(strcmp($row["tipo"], "Grupo") == 0){
                echo "<TABLE BORDER=1 style='color: whitesmoke;'>
                <TR>
                <TH>Código</TH>
                <TH>Nome</TH>
                <TH>Elementos</TH>
                </TR>
                <TR>
                <TD><center>$row[codigo] </center></TD>
                <TD><center>$row[nome]</center></TD>
                <TD><center>$row[qtd_elementos]</center></TD>
                </TR>
                </TABLE>";  
            }else{
                echo "<TABLE BORDER=1 style='color: whitesmoke;'>
                <font color: whitesmoke>                <TR>
                <TH>Código</TH>
                <TH>Nome</TH>
                <TH>Pais</TH>
                </TR>
                <TR>
                <TD><center>$row[codigo]</center></TD>
                <TD><center>$row[nome]</center></TD>
                <TD><center>$row[Pais_codigo]</center></TD>
                </TR>
                </font>
                </TABLE>"; 
            }
        }
    }
    

    function listarParticipantes($EdicaoNumero) {
    $result_set = $this->db_musisys->executarSQL("SELECT (SELECT nome FROM participante WHERE codigo=c.Participante_codigo) AS Participante, (SELECT nome FROM palco WHERE codigo=c.Palco_codigo AND Edicao_numero=c.Edicao_numero) AS Palco, Dia_festival_data, Participante_codigo FROM (contrata AS c) WHERE Edicao_numero = $EdicaoNumero");
    $tuplos = mysqli_num_rows($result_set);
    if ($tuplos==0) {
        echo "Nenhum participante registado <br>";
    }else{
        echo "<TABLE BORDER=1 style='color: whitesmoke;'>
            <TR>
            <TH style='width:100px; text-align:center;'>Artista</TH>
            <TH style='width:100px; text-align:center;'>Palco</TH>
            <TH style='width:100px; text-align:center;'>Data</TH>
            <TH style='width:100px; text-align:center;'></TH>
            <TH style='width:100px; text-align:center;'></TH>
            </TR>";
       for($registo=0; $registo<$tuplos; $registo++) {
            $row = mysqli_fetch_assoc($result_set);
           echo "
            <TR>
            <TD style='width:100px;'><center>$row[Participante]</center></TD>
            <TD style='width:100px;'><center>$row[Palco]</center></TD>
            <TD style='width:100px;'><center>$row[Dia_festival_data]</center></TD>
            <TD style='width:150px;'><form action=\"mudar_palco.php\" method=post>
                <input type=hidden name=participante value=$row[Participante_codigo]>
                <input type=hidden name=edicao value=$EdicaoNumero>
                <input type=submit style='width:150px;' value=\"Mudar Palco\">
                </form></TD>
            <TD style='width:150px;'><form action=\"cancelar_show.php\" method=post>
                <input type=hidden name=participante value=$row[Participante_codigo]>
                <input type=hidden name=edicao value=$EdicaoNumero>
                <input type=submit style='width:150px;' value=\"Cancelar\"></form></TD>
            </TR>";
        }
       echo "</TABLE>";
    }
}
    
   function procurarParticipantesAvancado($palco, $nEntrevistas){
       if(empty($palco) && empty($nEntrevistas)){
           echo "Nenhum dado inserido <br>";
           return;
       }else if(empty($palco)){
           $result_set = $this->db_musisys->executarSQL("SELECT * FROM participante WHERE ((SELECT COUNT(participante_codigo) FROM entrevista WHERE participante_codigo = codigo)>=$nEntrevistas)");
       }else if(empty($nEntrevistas)){
           $result_set = $this->db_musisys->executarSQL("SELECT * FROM participante WHERE (codigo IN (SELECT participante_codigo FROM contrata WHERE palco_codigo = (SELECT DISTINCT codigo FROM palco WHERE nome = '$palco')))");
       }else{
            $result_set = $this->db_musisys->executarSQL("SELECT * FROM participante WHERE (codigo IN (SELECT participante_codigo FROM contrata WHERE palco_codigo = (SELECT DISTINCT codigo FROM palco WHERE nome = '$palco'))) AND ((SELECT COUNT(participante_codigo) FROM entrevista WHERE participante_codigo = codigo)>=$nEntrevistas)");
       }
        $tuplos = mysqli_num_rows($result_set); 
       if ($tuplos==0) {
        echo "Nenhum Participante encontrado <br>";
        }else{
           echo "<TABLE BORDER=1 style='color: whitesmoke;'>
                <TR>
                <TH style='width:100px; text-align:center;'>Código</TH>
                <TH style='width:100px; text-align:center;'>Nome</TH>
                <TH style='width:100px; text-align:center;'>Pais</TH>
                <TH style='width:100px; text-align:center;'>Elementos</TH>
                </TR>";
           for($registo=0; $registo<$tuplos; $registo++) {
                $row = mysqli_fetch_assoc($result_set);
               echo "<TABLE BORDER=1 style='color: whitesmoke;'>
                <TR>
                <TD style='width:100px;'><center>$row[codigo]</center></TD>
                <TD style='width:100px;'><center>$row[nome]</center></TD>
                <TD style='width:100px;'><center>$row[Pais_codigo]</center></TD>
                <TD style='width:100px;'><center>$row[qtd_elementos]</center></TD>
                </TR>";
            }
           echo "</TABLE>";
       }
   }
    
    
    function fecharBDParticipantes() {
        $this->db_musisys->fecharBD();
    }
  
}

class Contrata extends BDMusisys {
    
    var $db_musisys;
    
    function Contrata(){
        $this->db_musisys = new BDMusisys;
        $this->db_musisys->ligarBD();
    }
    
    function cancelarContrata($nParticipante, $nEdicao){
        $this->db_musisys->executarSQL("DELETE FROM contrata WHERE Edicao_numero=$nEdicao AND Participante_codigo=$nParticipante");
    }
    
    function mudarPalco($nParticipante, $nEdicao, $palco){
        if(empty($palco)){
           echo "Nenhum dado inserido <br>";
           return;
        }
        $result_set = $this->db_musisys->executarSQL("SELECT codigo FROM palco WHERE (nome = '$palco') AND (Edicao_numero=$nEdicao)");
        if(mysqli_num_rows($result_set)==0){
            echo "Palco não encontrado ou não pertence à Edição <br>";
        }else{
            $row = mysqli_fetch_assoc($result_set);
            $this->db_musisys->executarSQL("UPDATE contrata SET Palco_codigo = $row[codigo] WHERE Edicao_numero = $nEdicao AND Participante_codigo = $nParticipante");
            echo "Palco Alterado <br>";
        }
    }
    
     function fecharBDContrata() {
        $this->db_musisys->fecharBD();
    }
  
}
?>
