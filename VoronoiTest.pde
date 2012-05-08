import toxi.math.conversion.*;
import toxi.geom.*;
import toxi.math.*;
import toxi.geom.mesh2d.*;
//import toxi.geom.nurbs.*;
import toxi.util.datatypes.*;
import toxi.util.events.*;
import toxi.geom.mesh.subdiv.*;
import toxi.math.waves.*;
import toxi.geom.mesh.*;
import toxi.util.*;
import toxi.math.noise.*;

/**
 * This demo shows the basic usage pattern of the Voronoi class in combination with
 * the SutherlandHodgeman polygon clipper to constrain the resulting shapes.
 *
 * Usage:
 * mouse click: add point to voronoi
 * p: toggle points
 * t: toggle triangles
 * x: clear all
 * r: add random
 * c: toggle clipping
 * h: toggle help display
 * space: save frame
 *
 * Voronoi class ported from original code by L. Paul Chew
 */

/* 
 * Copyright (c) 2010 Karsten Schmidt
 * 
 * This demo & library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * http://creativecommons.org/licenses/LGPL/2.1/
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */
import toxi.geom.*;
import toxi.geom.mesh2d.*;

import toxi.util.*;
import toxi.util.datatypes.*;

import toxi.processing.*;

//Image for portrait
PImage img;

// ranges for x/y positions of points
FloatRange xpos, ypos;

// helper class for rendering
ToxiclibsSupport gfx;

// empty voronoi mesh container
Voronoi voronoi = new Voronoi();

// optional polygon clipper
PolygonClipper2D clip;

// switches
boolean doShowPoints = false;
boolean doShowDelaunay;
boolean doShowHelp=false;
boolean doClip;
boolean doSave;

void setup() {
  //size(643, 477);
  size(400, 300);
  smooth();
  //img = loadImage("portrait_test_BlackAndWhite02.png");
  img = loadImage("kleeb.jpg");
  // focus x positions around horizontal center (w/ 33% standard deviation)
  xpos=new BiasedFloatRange(0, width, width/2, 0.333f);
  // focus y positions around bottom (w/ 50% standard deviation)
  ypos=new BiasedFloatRange(0, height, height, 0.5f);
  // setup clipper with centered rectangle
  clip=new SutherlandHodgemanClipper(new Rect(width*0.125, height*0.125, width*0.75, height*0.75));
  gfx = new ToxiclibsSupport(this);
  textFont(createFont("SansSerif", 10));
  
  pixelArray();
  
}

void draw() {
  background(255);
  stroke(0);
  noFill();

veronoiFunctions();
  
  
  
}

void keyPressed() {
  switch(key) {
  case ' ':
    doSave = true;
    break;
  case 't':
    doShowDelaunay = !doShowDelaunay;
    break;
  case 'x':
    voronoi = new Voronoi();
    break;
  case 'p':
    doShowPoints = !doShowPoints;
    break;
  case 'c':
    doClip=!doClip;
    break;
  case 'h':
    doShowHelp=!doShowHelp;
    break;
  case 'r':
    for (int i = 0; i < 10; i++) {
      voronoi.addPoint(new Vec2D(xpos.pickRandom(), ypos.pickRandom()));
    }
    break;
  }
}

void mousePressed() {
 // voronoi.addPoint(new Vec2D(mouseX, mouseY));
}

void addPoint(int x, int y){
  
         voronoi.addPoint(new Vec2D(x,y)); 
  
}

void veronoiFunctions(){
 // draw all voronoi polygons, clip them if needed...
  for (Polygon2D poly : voronoi.getRegions()) {
    if (doClip) {
      gfx.polygon2D(clip.clipPolygon(poly));
    } 
    else {
      gfx.polygon2D(poly);
    }
  }
  // draw delaunay triangulation
  if (doShowDelaunay) {
    stroke(0, 0, 255, 50);
    beginShape(TRIANGLES);
    for (Triangle2D t : voronoi.getTriangles()) {
      gfx.triangle(t, false);
    }
    endShape();
  }
  // draw original points added to voronoi
  if (doShowPoints) {
    fill(255, 0, 255);
    noStroke();
    for (Vec2D c : voronoi.getSites()) {
      ellipse(c.x, c.y, 5, 5);
    }
  }
  if (doSave) {
    saveFrame("voronoi-" + DateUtils.timeStamp() + ".png");
    doSave = false;
  }
  if (doShowHelp) {
    fill(255, 0, 0);
    text("p: toggle points", 20, 20);
    text("t: toggle triangles", 20, 40);
    text("x: clear all", 20, 60);
    text("r: add random", 20, 80);
    text("c: toggle clipping", 20, 100);
    text("h: toggle help display", 20, 120);
    text("space: save frame", 20, 140);
  } 
}

void pixelArray(){
 loadPixels();

  // We must also call loadPixels() on the PImage since we are going to read its pixels.
  img.loadPixels();
  for (int y = 0; y < height; y++ ) {
    for (int x = 0; x < width; x++ ) {
      int loc = x + y*width;
      // The functions red(), green(), and blue() pull out the three color components from a pixel.
      float r = red(img.pixels [loc]); 
      float g = green(img.pixels[loc]);
      float b = blue(img.pixels[loc]);

      float h = hue(img.pixels [loc]);
      float s = saturation(img.pixels [loc]);
      float br = brightness(img.pixels [loc]);


      colorMode(HSB);
//      if (br<50){
//        voronoi.addPoint();
//        //(new Vec2D(mouseX, mouseY));
//      }
      if (br < 45) {
        
        if(random(1) < 0.07){
        
        addPoint(x,y);
        println("x: " + x + ", y: " + y);
        }        
  }
      // Image Processing would go here
      // If we were to change the RGB values, we would do it here, before setting the pixel in the display window.

      // Set the display pixel to the image pixel
      //colorMode(HSB);
      pixels[loc] = color(h, s, br);
    }
  }

  //commented out to not draw the image
 // updatePixels(); 



}
