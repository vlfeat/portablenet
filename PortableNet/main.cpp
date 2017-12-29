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
  for(int i = 1; i < argc; i++){
    cout << "Test " << i << endl;
    cout << "Enter 0 if you want to output the class with maximum probability" << endl ;
    cout << "Enter 1 if you want to output all classes with associated probability" << endl ;
    int option ;
    cin >> option ;
    Program program ;
    Workspace ws ;
    ws.baseName("data/lenet") ;
    ws.inputName(argv[i]);
    ws.printMethod(option);
    program.load("data/lenet") ;
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
