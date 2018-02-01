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
//  cout << "Enter 0 if you want to output top 1 class with maximum probability" << endl ;
//  cout << "Enter 1 if you want to output top 5 classes with associated probability" << endl ;
//  int option ;
//  cin >> option ;
  for(int i = 1; i < argc; i++){
    cout << endl ;
    cout << "Test " << i << endl;
    Program program ;
    Workspace ws ;
    ws.baseName("data/resnet") ;
    ws.inputName(argv[i]);
    ws.printMethod(0);
    program.load("data/resnet") ;
    //program.print() ;
    {
      ErrorCode error = program.execute(ws) ;
      if (error != VLE_Success) {
      cerr << "Error: " << globalContext.getLastErrorMessage() << endl ;
    }
  }
  ws.print();
}
  return 0;
}
  
