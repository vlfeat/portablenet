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
  Program program ;
  Workspace ws ;
  ws.baseName("data/alexnet.mcn") ;
  program.load("data/alexnet.mcn") ;
  program.print() ;
  {
    ErrorCode error = program.execute(ws) ;
    if (error != VLE_Success) {
      cerr << "Error: " << globalContext.getLastErrorMessage() << endl ;
    }
  }
  ws.print() ;

  return 0;
}
