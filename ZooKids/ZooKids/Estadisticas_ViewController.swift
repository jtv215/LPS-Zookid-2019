//
//  Estadisticas_ViewController.swift
//  ZooKids
//
//  Created by Jose F. Ruiz Zamora on 25/12/18.
//  Copyright © 2018 ual. All rights reserved.
//

import UIKit
import CoreData

class Estadisticas_ViewController: ViewController {

    @IBOutlet weak var selectorEstadistica: UISegmentedControl!
    @IBOutlet weak var estadisticaResultado: UIView!
    @IBOutlet weak var textoGrafica: UILabel!
    @IBOutlet weak var EstadisticaGenero: UIView!
    
    @IBOutlet weak var EstadisticaFallosTotales: UIView!
    
    var aciertosTotales : Int16 = 0
    var fallosTotales : Int16 = 0
    var numAciertosH:Int16 = 0
    var numFallosH:Int16 = 0
    var numAciertosM:Int16 = 0
    var numFallosM:Int16 = 0
    var tipoAnimalMap = Dictionary<String,Int16>()
    
    
    @IBAction func salir(sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Admin", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("viewAdmin") as UIViewController
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        navigationController?.navigationBar.barTintColor = UIColor(red:0.56, green:0.91, blue:0.85, alpha:1.0)
        let btnImage = UIButton()
        btnImage.setImage(UIImage(named: "Logo Item Bar"), forState: .Normal)
        btnImage.frame=CGRectMake(0,0,40,40)
        btnImage.userInteractionEnabled = false
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = btnImage
        self.navigationItem.rightBarButtonItem = rightBarButton
        super.viewDidLoad()

        //Cargar estadísticas al iniciar la ventana
        self.cargarEstadisticas()
        self.cambiarTextoGrafica()
        
        //print("Childs = ", self.childViewControllers)
        
        //ChildViewController 0 = GraficaResultadosViewController
        let graficaResultado = self.childViewControllers[0] as! GraficaResultadosViewController
        graficaResultado.aciertos = aciertosTotales
        graficaResultado.fallos = fallosTotales
        graficaResultado.viewDidLoad()
        
        //ChildViewController 1 = GraficaGeneroViewController
        let graficaGenero = self.childViewControllers[1] as! GraficaGeneroViewController
        graficaGenero.aciertosM = self.numAciertosM
        graficaGenero.fallosM = self.numFallosM
        graficaGenero.aciertosH = self.numAciertosH
        graficaGenero.fallosH = self.numFallosH
        graficaGenero.viewDidLoad()
        
        //ChildViewController 2 = GraficaFallosTotalesViewController
        let graficaFallos = self.childViewControllers[2] as! GraficaFallosTotalesViewController
        graficaFallos.tipoAnimalMap = self.tipoAnimalMap
        graficaFallos.viewDidLoad()
        
        
        //Actualizar valores al cambiar de pestaña
        //selectorEstadistica.addTarget(self, action: #selector(self.changeValue(_:)), forControlEvents: .ValueChanged)
        
        
        estadisticaResultado.hidden=false
        EstadisticaGenero.hidden=true
        textoGrafica.hidden = false
        EstadisticaFallosTotales.hidden=true
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cargarEstadisticas(){
    
        //Cargar fallos totales
        //Configurar contexto
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        //Partidas totales
        let fetchRequestPartidas = NSFetchRequest(entityName: "Partida")
        //Cargar todas las partidas que pertenecen al admin
        fetchRequestPartidas.predicate = NSPredicate(format: "alumno.profesor.nombre_usuario == %@", profesor.nombre_usuario)
        var preguntasTotales:Int16 = 0
        var erroresTotales = 0 as Int16
        do{
            let resultsPartidas = try managedContext.executeFetchRequest(fetchRequestPartidas)
            //preguntasTotales = resultsPartidas.count * 25
            //Errores
            for partida in resultsPartidas as! [Partida]{
                /*if(partida.alumno.profesor.nombre_usuario != profesor.nombre_usuario){
                    continue
                }*/
                preguntasTotales += partida.num_aciertos + partida.num_fallos
                erroresTotales += partida.num_fallos
            }
            
        }catch{
            print("Error")
        }
        
        //Fallos totales
        let fetchRequestFallos = NSFetchRequest(entityName: "Fallo")
        fetchRequestFallos.predicate = NSPredicate(format: "admin.nombre_usuario == %@", profesor.nombre_usuario)
        //var fallosTotales : Int16 = 0
        //var tipoAnimalMap = Dictionary<String,Int16>()
        tipoAnimalMap = initializeDictionary()
        do{
            let resultsFallos = try managedContext.executeFetchRequest(fetchRequestFallos)
            fallosTotales = 0
            
            for fallo in resultsFallos as! [Fallo]{
                //print("Fallo ",fallo.tipo_animal," total de ",fallo.fallos, "fallos")
                fallosTotales += fallo.fallos
                tipoAnimalMap[fallo.tipo_animal] = tipoAnimalMap[fallo.tipo_animal]!+fallo.fallos
                
            }
            
        }
        catch{
            print("error")
        }
        
        
        //Por género
        let fetchRequestGenero = NSFetchRequest(entityName: "Partida")
        fetchRequestGenero.predicate = NSPredicate(format: "alumno.profesor.nombre_usuario == %@", profesor.nombre_usuario)
        
        do{
            
            let resultsFallosGenero = try managedContext.executeFetchRequest(fetchRequestGenero)
            
            for partida in resultsFallosGenero as! [Partida]{
                /*if(partida.alumno.profesor.nombre_usuario != profesor.nombre_usuario){
                    continue
                }*/
                //print("partida id = ",partida.id_partida)
                if(partida.alumno.sexo == "M"){
                    //print("género = M")
                    numAciertosM += partida.num_aciertos
                    numFallosM += partida.num_fallos
                }else{
                    //print("género = H")
                    numAciertosH += partida.num_aciertos
                    numFallosH += partida.num_fallos
                }
            }
            
            
        }
        catch{
            print("error")
        }

        
        //Datos para las estadísticas
        //let aciertosTotales = numAciertosM + numFallosH
        aciertosTotales = numAciertosM + numAciertosH
        
        /*
        print("Errores totales = ",String(erroresTotales))
        print("Preguntas totales = ",preguntasTotales)
        print("Fallos totales = ",fallosTotales," ; fallos H = ",numFallosH," ; fallos M = ",numFallosM)
        print("Aciertos totales = ",aciertosTotales," ; aciertos H = ",numAciertosH,
              " ; aciertos M = ",numAciertosM)
        print("Errores por animal: ",tipoAnimalMap)
        */
        

        
    }
    
    //Modificar texto de resumen de los datos
    func cambiarTextoGrafica(){
        
        var primerTexto: String = ""
        var segundoTexto: String = ""
        var tercerTexto: String = ""
        if(aciertosTotales+fallosTotales==0){
            primerTexto = "❗️ No se tienen datos de partidas todavía"
            segundoTexto = ""
            tercerTexto = ""
        }else{
            //Primer texto
            if(aciertosTotales == fallosTotales){
                primerTexto = "⏸ Hay los mismos aciertos ("+String(aciertosTotales)+") que fallos ("+String(fallosTotales)+")"
            }else if(aciertosTotales > fallosTotales){
                primerTexto = "✅ Hay un mayor número de aciertos ("+String(aciertosTotales)+") que de fallos ("+String(fallosTotales)+")"
            }else{
                primerTexto = "❌ Hay un mayor número de fallos ("+String(fallosTotales)+") que de aciertos ("+String(aciertosTotales)+")"
            }
            
            //Segundo texto
            if(numFallosH < numFallosM && numAciertosH > numAciertosM){
                segundoTexto = "👦 Los niños tienen más aciertos y menos fallos totales"
            }else if(numFallosM < numFallosM && numAciertosM > numAciertosH){
                segundoTexto = "👧 Las niñas tienen más aciertos y menos fallos totales"
            }else{
                if(numFallosH == numFallosM && numAciertosH == numAciertosM){
                    segundoTexto = "👫 Niños y niñas tienen el mismo número de fallos ("+String(numFallosM)+") y de aciertos ("+String(numAciertosM)+")"
                }else{
                    if(numAciertosM > numAciertosH){
                        segundoTexto = "🙋‍♀️ Las niñas tienen más número de aciertos"
                    }else if (numAciertosH > numAciertosM){
                        segundoTexto = "🙋‍♂️ Los niños tienes más número de aciertos"
                    }
                    
                    if(numFallosH > numFallosM){
                        segundoTexto += "\n🙅‍♂️ Los niños tienen más número de fallos"
                    }else if(numFallosM > numFallosH){
                        segundoTexto += "\n🙅‍♀️ Las niñas tienen más número de fallos"
                    }
                }
            }
            
            //Tercer texto
            var aux:Int16 = 0
            var str = ""
            for (key,value) in tipoAnimalMap{
                print("key = ",key," value = ",String(value))
                if(value > aux){
                    aux = value
                    str = key
                }
            }
            if(aux == 0){
                tercerTexto = ""
            }else{
                tercerTexto = "🐶 El animal que más se falla es: "+str
            }
            
        }
        
        
        textoGrafica.text = primerTexto + ".\n"+segundoTexto+".\n"+tercerTexto
        textoGrafica.numberOfLines = 0
        //textoGrafica.sizeToFit()
        
    }

    
    @IBAction func indexChanged(sender: AnyObject) {
        
        
        switch selectorEstadistica.selectedSegmentIndex
        {
        case 0:
            estadisticaResultado.hidden=false
            EstadisticaGenero.hidden=true
            textoGrafica.hidden = false
            EstadisticaFallosTotales.hidden=true
            
        case 1:
            estadisticaResultado.hidden=true
            EstadisticaGenero.hidden=false
            textoGrafica.hidden = true
            EstadisticaFallosTotales.hidden=true
           
            
        case 2:
      
             estadisticaResultado.hidden=true
             EstadisticaGenero.hidden=true
            textoGrafica.hidden = true
            EstadisticaFallosTotales.hidden=false

            
        default:
            break
        }
        
        
    }
    
    
    
    
    func initializeDictionary() -> Dictionary<String,Int16>{
     
        var map = Dictionary<String,Int16>()
        var opciones_totales = [String]();
        opciones_totales.append("Mamífero");
        opciones_totales.append("Pez");
        opciones_totales.append("Anfibio");
        opciones_totales.append("Reptil");
        opciones_totales.append("Invertebrado");
        opciones_totales.append("Insecto");
        opciones_totales.append("Ave");
        
        for str in opciones_totales{
            map[str] = 0
        }
        return map;
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
