<html>
<meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
    <head>
        <title>Musisys</title>
        <link rel="icon" type="image/png" href="images/favicon.png" />
        
        <style>
            * {
                box-sizing: border-box;
            }

            body {
                font-family: Arial, Helvetica, sans-serif;
            }


            header {
                background-color: #FFF;
                text-align: center;
                font-size: 35px;
                color: dimgray;
            }


            nav {
                float: left;
                width: 20%;
                height: 60%; 
                background: grey;
                padding: 20px;
            }


            nav ul {
                list-style-type: none;
                padding: 0;
            }

            content {
                float: left;
                padding: 20px;
                width: 100%;
                background-color: #f1f1f1;
                height: 50%; 
                background: linear-gradient(to top, #003366, #4ea5d8);
                color: whitesmoke;
                text-shadow: 2px 0 black, -2px 0 black, 0 2px black, 0 -2px black,
               1px 1px black, -1px -1px black, 1px -1px black, -1px 1px black;
            }


            section::after {
                content: "";
                display: table;
                clear: both;
            }


            footer {
                background-color: #003366;
                padding: 10px;
                text-align: right;
                color: whitesmoke;
                text-shadow: 2px 0 black, -2px 0 black, 0 2px black, 0 -2px black,
               1px 1px black, -1px -1px black, 1px -1px black, -1px 1px black;
            }


            @media (max-width: 600px) {
                nav, content {
                width: 100%;
                height: auto;
                }
            }
            
            .tab {
                display: inline-block;
                margin-left: 4em;
            }
            
            input[type=submit] {
                width: 12em;  
                height: 2em; 
                font-size: 1.12em;
            }   
        </style>
        
    </head>
    <body>
        <center>
            <header>
                <img style="width: 100%;" src="images/header.png"/>
            </header>
            
            <section>
                <content>
                    <Center>    
                      
                        
                        <p><h3>Mudar Palco:</h3></p> 
                        <form method="post" action="efetua_mudar_palco.php">
                        <label for="palco">Inserir nome: </label>
                        <input type="text" name=palco size="30" maxlength="30">
                         <input type="hidden" name="participante" value="<?php echo $_POST['participante']; ?>">
                            <input type="hidden" name="edicao" value="<?php echo $_POST['edicao']; ?>">
                        <br><br>
                        <input type="submit" name="Submit" value="Introduzir">
                    </form>
                        <br><br><br>
                        <form action=proximas_edicoes.php>
                            <input type=submit value="Voltar">
                        </form>
                        <form action=menu.html>
                            <input type=submit value="Voltar ao menu">
                        </form>
                    </Center>
                </content>
            
            </section>
            
            <footer>
                Powered by: Diogo Pereira - 110976 
                <br> Bruno Silva - 100005
            </footer>
            
            
        </center>
    </body>
</html>