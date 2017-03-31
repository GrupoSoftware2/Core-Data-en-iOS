//
//  ViewController.swift
//  Core Data en iOS
//
//  Created by Admin on 3/30/17.
//  Copyright © 2017 ourlimm. All rights reserved.
//

import UIKit
import MBProgressHUD
import CoreData
import ReachabilitySwift


class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tvpublicaciones: UITableView!
    
    
    var publicaciones = Array<publicacion>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listaCoreData()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return publicaciones.count
    }
    
    
    func listaCoreData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName:"Publicacion")
        
        do{
            let resultado = try context.fetch(fetchRequest)
            
            for item in resultado{
                //convertir NSManagedObject a publicacion
                
                let publicacionda = publicacion()
                
                
                publicacionda.titulo = item.value(forKey: "titulo") as! String!
                publicacionda.contenido = item.value(forKey: "contenido") as! String!
                
                self.publicaciones.append(publicacionda)
            }
            
        }catch let error as NSError{
            print(error.userInfo)
        }
    }
    
    
    func registrarEnCoreData(listado : Array<publicacion>){
        
        for item in listado{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            let context = appDelegate.persistentContainer.viewContext
            
            let entity = NSEntityDescription.entity(forEntityName: "Publicacion", in: context)
            
            let publicacion = NSManagedObject(entity: entity!, insertInto: context)
            
            publicacion.setValue(item.titulo, forKey: "titulo")
            publicacion.setValue(item.contenido, forKey: "contenido")
            
            do{
                
                try context.save()
                //print(item.titulo + "se registro correctamente")
            }catch let error as NSError{
                print(item.titulo + "bi se registro correctamente: \(error.userInfo)")
            }
            
            
        }
    }
    
    
    func eliminarDeCoreData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName:"Publicacion")
        

        do{

            let result = try context.fetch(fetchRequest)
            
            for item in result{
                context.delete(item)
            }
            
            try context.save()
            
        }catch let error as NSError {
            print(error.userInfo)
        }
        
    }
    
    func obtenerPublicaciones(){
        
        print("Entre a obtener")
        //Comprobrar si tengo internet
        let reachability = Reachability()
        
        
        
        reachability?.whenReachable = { reachability in
            
            
            self.publicaciones.removeAll()
            let hub  = MBProgressHUD(view : self.view)
            hub.show(animated: true)
            hub.label.text = "Cargando...."
            
            self.view.addSubview(hub)
            
            PublicacionWebService.listarTodo { (jsonResultado) in
                
                //Eliminar Desactualizados
                self.eliminarDeCoreData()
                
                //Registrar Actualizado
                self.registrarEnCoreData(listado: jsonResultado)
                
                
                //self.publicaciones = jsonResultado
                
                //Mostrar eb TableView
                self.tvpublicaciones.reloadData()
                hub.hide(animated: true)
                
            }

            
        }
        
        
        reachability?.whenUnreachable = { reachability in
            var alertController:UIAlertController
            
            alertController = UIAlertController(title: "Advertencia", message: "No cuenta con conexion a Internet para realizar esta peticiion. Gracias", preferredStyle: UIAlertControllerStyle.alert)
            
            let accionOk  = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
                print("Presiono OK")
            })
            
            alertController.addAction(accionOk)
            self.present(alertController, animated: true, completion: {
                
            })
        }
        
        
        do{
            
            try reachability?.startNotifier()
            
        }catch let error as NSError{
            print(error.description)
        }
        
        reachability?.stopNotifier()
        
        /**for i in 1...8{
         
         let publi =  publicacion()
         publi.titulo = "publicacion \(i)"
         publi.contenido = "contenido \(i)"
         publicaciones.append(publi)
         }
         **/
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let publi = publicaciones[indexPath.row]
        
        self.performSegue(withIdentifier: "detalle", sender: publi)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if  segue.identifier == "detalle"{
            
            //let detallecontroler = segue.destination as! DetalleViewController
            
            //detallecontroler.publi = sender as! publicacion
            
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "celda", for: indexPath) as! PublicacionCelda
        
        let indice = indexPath.row
        
        let publi = publicaciones[indice]
        
        cell.lbltitulo.text = publi.titulo
        cell.txtcontenido.text = publi.contenido
        
        return cell
    }
    
    @IBAction func cargarpublicaciones(_ sender: UIBarButtonItem) {
        self.obtenerPublicaciones()
    }
    
    
    
}

