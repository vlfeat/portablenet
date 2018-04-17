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
#include <chrono>

#include "Program.hpp"

using namespace std ;
using namespace vl ;
// Record start time
auto start = std::chrono::high_resolution_clock::now();
int main(int argc, const char * argv[])
{
//  cout << "Enter 0 if you want to output top 1 class with maximum probability" << endl ;
//  cout << "Enter 1 if you want to output top 5 classes with associated probability" << endl ;
//  int option ;
//  cin >> option ;
  cout << endl ;
  Program program ;
  Workspace ws ;
  ws.baseName("data/resnet") ;
  ws.printMethod(0);
  program.load("data/resnet") ;
  //program.print() ;
  for(int i = 1; i < argc; i++){
    {
      ws.inputName(argv[i]);
      ErrorCode error = program.execute(ws) ;
      if (error != VLE_Success) {
        cerr << "Error: " << globalContext.getLastErrorMessage() << endl ;
      }
    }
    cout << "Test " << i << endl;
    ws.print();
  }
  // Record end time
  auto finish = std::chrono::high_resolution_clock::now();
  std::chrono::duration<double> elapsed = finish - start;
  std::cout << "Elapsed time: " << elapsed.count() << " s\n";
  return 0;
}

