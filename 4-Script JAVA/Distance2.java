package com.bdeb.UDF;

import org.apache.hadoop.hive.ql.exec.UDF;


public class Distance2 extends UDF{

//	public static void main(String[] args) {
//		
//		// lat/long 45.555277 -73.668172
//		//  
//		System.out.print("longitude 1 lattitude 1 : ");
//		double long1 = -73.668172;
//		double lat1 = 45.555277;
//		System.out.print("longitude 2 lattitude 2 : ");
//		double long2 = -73.559729;
//		double lat2 = 45.506165;
//		
//		double res = get_distance(lat1, long1, lat2, long2);
//		System.out.print("Distance : " + res/1000 + " km");
//	}
	
	private double deg2rad(double x) {
		return Math.PI * x / 180;
	}

	public double evaluate (double lat1, double lng1, double lat2, double lng2) {
		int earth_radius = 6378137; // Terre = sphère de 6378km de rayon

		double rlo1 = deg2rad(lng1); // CONVERSION
		double rla1 = deg2rad(lat1);
		double rlo2 = deg2rad(lng2);
		double rla2 = deg2rad(lat2);
		double dlo = (rlo2 - rlo1) / 2;
		double dla = (rla2 - rla1) / 2;
		double a = (Math.sin(dla) * Math.sin(dla)) + Math.cos(rla1) * Math.cos(rla2) * (Math.sin(dlo) * Math.sin(dlo));
		double d = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
		return earth_radius * d;
	}
}
