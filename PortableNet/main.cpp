//
//  main.cpp
//  PortableNet
//
//  Created by Andrea Vedaldi on 13/10/2017.
//  Copyright © 2017 VGG. All rights reserved.
//

#include <iostream>
#include <fstream>
#include <memory>

#include "Program.hpp"

using namespace std ;
using namespace vl ;

int main(int argc, const char * argv[])
{
  /*TensorShape y_shape(1,1,1,1) ;
  auto y_size = y_shape.getNumElements() * sizeof(float) ;
  auto y_memory = make_unique<float[]>(y_size) ;
  Tensor y(y_shape, VLDT_Float, VLDT_CPU, y_memory.get(), y_size) ;

  TensorShape x_shape(1,1,1,1) ;
  auto x_size = x_shape.getNumElements() * sizeof(float) ;
  auto x_memory = make_unique<float[]>(x_size) ;
  Tensor x(x_shape, VLDT_Float, VLDT_CPU, x_memory.get(), x_size) ;

  TensorShape w_shape(1,1,1,1) ;
  auto w_size = x_shape.getNumElements() * sizeof(float) ;
  auto w_memory = make_unique<float[]>(w_size) ;
  Tensor w(w_shape, VLDT_Float, VLDT_CPU, w_memory.get(), w_size) ;

  TensorShape b_shape(1,1,1,1) ;
  auto b_size = x_shape.getNumElements() * sizeof(float) ;
  auto b_memory = make_unique<float[]>(b_size) ;
  Tensor b(b_shape, VLDT_Float, VLDT_CPU, b_memory.get(), b_size) ;

  y_memory[0] = 0 ;
  x_memory[0] = 2 ;
  w_memory[0] = 4 ;
  b_memory[0] = 3 ;

  Context ctx ;

  nn::Convolution op(ctx,1,1,0,0,0,0,1,1) ;
  op.forward(y,0,x,1,w,b) ;

  cout << "y = " << y_memory[0] << endl ;*/

  // Try some more complex code.
  Program program ;
  Workspace ws ;
  ws.baseName("data/lenet.mat") ;
  program.load("data/lenet.mat") ;
  program.print() ;
  program.execute(ws) ;
  ws.print() ;

  return 0;
}
