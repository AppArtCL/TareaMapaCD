//
//  ViewController.swift
//  TareaMapaCD
//
//  Created by Cristian Diaz on 28-01-16.
//  Copyright © 2016 AppArt. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    // MARK: - Conexiones
    @IBOutlet weak var mapa: MKMapView!
    
    @IBAction func cambiarMapaStandard() {
        if self.mapa.mapType != MKMapType.Standard {
            mapa.mapType = MKMapType.Standard
        }
    }
    
    @IBAction func cambiarMapaSatelite() {
        if self.mapa.mapType != MKMapType.Satellite {
            mapa.mapType = MKMapType.Satellite
        }
    }
    
    @IBAction func cambiarMapaHibrido() {
        if self.mapa.mapType != MKMapType.Hybrid {
            mapa.mapType = MKMapType.Hybrid
        }
    }

    @IBOutlet weak var indicadorActividad: UIActivityIndicatorView!
    
    
    // MARK: - Variables
    private let administradorUbicacion = CLLocationManager()
    var referenciaUbicacion = CLLocation()
    var distanciaTotal = 0.0
    var listo = false
    
    // MARK: - Funciones
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Color negro para la barra de navegación
        let navBarColor = navigationController!.navigationBar
        navBarColor.barTintColor = UIColor(red:  0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 100.0/100.0)
        navBarColor.barStyle = UIBarStyle.Black
        navBarColor.tintColor = UIColor.whiteColor()
        navBarColor.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]

        // Inicializar variable
        self.distanciaTotal = 0.0
        self.listo = false

        // Configurar indicador
        indicadorActividad.startAnimating()
        indicadorActividad.color = UIColor.blackColor()
        
        // Conectar administrador
        administradorUbicacion.delegate = self
        administradorUbicacion.desiredAccuracy = kCLLocationAccuracyBest
        administradorUbicacion.requestWhenInUseAuthorization()
        
        // Tipo de mapa inicial
        mapa.mapType = MKMapType.Standard
        mapa.zoomEnabled = false
        mapa.rotateEnabled = false
        mapa.scrollEnabled = false
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if listo {
            let nuevaUbicacion = self.administradorUbicacion.location!
            let distancia = self.referenciaUbicacion.distanceFromLocation(nuevaUbicacion)
            if distancia > 50 {
                mapa.setCenterCoordinate(nuevaUbicacion.coordinate, animated: true)
                self.referenciaUbicacion = nuevaUbicacion
                self.distanciaTotal = self.distanciaTotal + distancia
                let chinche = MKPointAnnotation()
                chinche.title = String("Lat:\(nuevaUbicacion.coordinate.latitude); Lon:\(nuevaUbicacion.coordinate.longitude)")
                chinche.subtitle = String("Distancia total: \(Int(distanciaTotal)) [m].")
                chinche.coordinate = nuevaUbicacion.coordinate
                mapa.addAnnotation(chinche)
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            administradorUbicacion.startUpdatingLocation()
            while administradorUbicacion.location == nil {
                print(administradorUbicacion.location)
            }
            referenciaUbicacion = administradorUbicacion.location!
            self.listo = true
            mapa.setCenterCoordinate(referenciaUbicacion.coordinate, animated: true)
            mapa.showsUserLocation = true
            let chinche = MKPointAnnotation()
            chinche.title = String("Lat:\(referenciaUbicacion.coordinate.latitude); Lon:\(referenciaUbicacion.coordinate.longitude)")
            chinche.subtitle = String("Distancia total: \(Int(distanciaTotal)) [m].")
            chinche.coordinate = referenciaUbicacion.coordinate
            mapa.addAnnotation(chinche)
            let zona = MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
            let regionSeleccionada = MKCoordinateRegion(center: referenciaUbicacion.coordinate, span: zona)
            mapa.setRegion(regionSeleccionada, animated: true)
        } else {
            administradorUbicacion.stopUpdatingLocation()
            mapa.showsUserLocation = false
        }
        indicadorActividad.stopAnimating()
    }
    
}