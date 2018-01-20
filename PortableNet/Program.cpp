//
//  network.cpp
//  PortableNet
//
//  Created by Andrea Vedaldi on 15/10/2017.
//  Copyright © 2017 VGG. All rights reserved.
//

#include "Program.hpp"
#include "json.hpp"

#include <iostream>
#include <fstream>
#include <memory>
#include <cstdio>
#include <algorithm>
#include <cmath>

using namespace std ;
using namespace nlohmann ;
using namespace vl ;

vl::Context globalContext ;

typedef enum {
  MAX1 ,
  MAX5
} printMethod ;

// MARK: - Workspace

void Workspace::print() const
{

//  auto rit = tensors.rbegin() ;
//
//  assert(rit != tensors.rend()) ;
//
//  auto const & tensor = rit->second;
  
  // Search if such a tensor exists.
  Tensor tensor ;
  
  auto const& found = tensors.find("x21") ;
  if (found != tensors.end()) {tensor = found->second ; }
  
  // Initialize counter
  double max_double = 0 ;
  int max_counter = 0 ;
  float max_float = 0 ;
  char max_char = 0 ;
  
  // Initialize counter for max 5 output
  vector<bool> tracker(1000, false) ;
  const int n = 5 ;
  vector<double> topN_double ;
  vector<float> topN_float ;
  vector<char> topN_char ;
  vector<int> topNIndex ;
  
  if (tensor.getMemory()) {
      switch (printmethod()) {
          case MAX1:
          cout << endl ;
          cout << "Results:" << endl ;
          cout << "Class with max score" << endl ;
      
            switch (tensor.getDataType()) {
              case VLDT_Double: {
                for (int counter = 0; counter < 1000; counter++) {
                if (abs(static_cast<double const*>(tensor.getMemory())[counter]) > max_double) {
                  max_double = abs(static_cast<double const*>(tensor.getMemory())[counter]) ;
                  max_counter = counter ;
                }
                }
                // Find the class description
                auto const& label = descriptions.find(max_counter) ;
                cout << "class: " << label->second << "\t\t" << "score: " << max_double << endl ;
                break ;
              }
              case VLDT_Float:{
                for (int counter = 0; counter < 1000; counter++) {
                if (abs(static_cast<float const*>(tensor.getMemory())[counter]) > max_float) {
                  max_float = abs(static_cast<float const*>(tensor.getMemory())[counter]) ;
                  max_counter = counter ;
                }
                }
                // Find the class description
                auto const& label = descriptions.find(max_counter) ;
                cout << "class: " << label->second << "\t\t" << "score: " << max_float << endl ;
                break ;
              }
              case VLDT_Char:{
                for (int counter = 0; counter < 1000; counter++) {
                if (abs(static_cast<char const*>(tensor.getMemory())[counter]) > max_char) {
                  max_char = abs(static_cast<char const*>(tensor.getMemory())[counter]) ;
                  max_counter = counter;
                }
                }
                // Find the class description
                auto const& label = descriptions.find(max_counter) ;
                cout << "class: " << label->second << "\t\t" << "score: " << max_char << endl ;
                break ;
              }
          }
          break ;
          
          case MAX5:
          cout << endl ;
          cout << "Results:" << endl ;
          cout << "Top 5 Classes with associated scores" << endl ;
          
          switch (tensor.getDataType()) {
            case VLDT_Double:
              
              for(int i = 0; i < n; i++){
                int unmarked_index = 0 ;
                for(; unmarked_index < tracker.size(); unmarked_index++){
                  if(!tracker[unmarked_index]){
                    break ;
                  }
                }
                
                double max = abs(static_cast<double const*>(tensor.getMemory())[unmarked_index]) ;
                int max_index = unmarked_index ;
                for (int j = unmarked_index + 1; j < tracker.size(); j++) {
                  if(!tracker[j] && abs(static_cast<double const*>(tensor.getMemory())[j]) > max){
                    max = abs(static_cast<double const*>(tensor.getMemory())[j]) ;
                    max_index = j ;
                  }
                }
                tracker[max_index] = true ;
                topN_double.push_back(max) ;
                topNIndex.push_back(max_index) ;
              }
              
              for(int i = 0; i < topN_double.size(); i++){
                // Find the class description
                auto const& label = descriptions.find(topNIndex[i]) ;
                cout << "class: " << label->second << "\t\t" << "score: " << topN_double[i] << endl ;
              }
            break ;
                
            case VLDT_Float:
                for(int i = 0; i < n; i++){
                  int unmarked_index = 0 ;
                  for(; unmarked_index < tracker.size(); unmarked_index++){
                    if(!tracker[unmarked_index]){
                      break ;
                    }
                  }
                  
                  float max = abs(static_cast<float const*>(tensor.getMemory())[unmarked_index]) ;
                  int max_index = unmarked_index ;
                  for (int j = unmarked_index + 1; j < tracker.size(); j++) {
                    if(!tracker[j] && abs(static_cast<float const*>(tensor.getMemory())[j]) > max){
                      max = abs(static_cast<float const*>(tensor.getMemory())[j]) ;
                      max_index = j ;
                    }
                  }
                  tracker[max_index] = true ;
                  topN_float.push_back(max) ;
                  topNIndex.push_back(max_index) ;
                }
              
              for(int i = 0; i < topN_float.size(); i++){
                // Find the class description
                auto const& label = descriptions.find(topNIndex[i]) ;
                cout << "class: " << label->second << "\t\t" << "score: " << topN_float[i] << endl ;
              }
              break ;
                  
            case VLDT_Char:
                  for(int i = 0; i < n; i++){
                    int unmarked_index = 0 ;
                    for(; unmarked_index < tracker.size(); unmarked_index++){
                      if(!tracker[unmarked_index]){
                        break ;
                      }
                    }
                    
                    char max = abs(static_cast<char const*>(tensor.getMemory())[unmarked_index]) ;
                    int max_index = unmarked_index ;
                    for (int j = unmarked_index + 1; j < tracker.size(); j++) {
                      if(!tracker[j] && abs(static_cast<char const*>(tensor.getMemory())[j]) > max){
                        max = abs(static_cast<char const*>(tensor.getMemory())[j]) ;
                        max_index = j ;
                      }
                    }
                    tracker[max_index] = true ;
                    topN_char.push_back(max) ;
                    topNIndex.push_back(max_index) ;
                  }
              
              for(int i = 0; i < topN_char.size(); i++){
                // Find the class description
                auto const& label = descriptions.find(topNIndex[i]) ;
                cout << "class: " << label->second << "\t\t" << "score: " << topN_char[i] << endl ;
              }
              break ;
          
//          for (int counter = 0; counter < 1000; counter++) {
//            switch (tensor.getDataType()) {
//              case VLDT_Double:
//                cout << "class: " << counter << "\t\t" << "score: " << static_cast<double const*>(tensor.getMemory())[counter] << endl ;
//                break ;
//              case VLDT_Float:
//                cout << "class: " << counter << "\t\t" << "score: " << static_cast<float const*>(tensor.getMemory())[counter] << endl ;
//                break ;
//              case VLDT_Char:
//                cout << "class: " << counter << "\t\t" << "score: " << static_cast<char const*>(tensor.getMemory())[counter] << endl ;
//                break ;
//            }
//      }
      
    }
      cout << endl;
      }
    }else {
      cout << "<No Data>" ;
    }
  }

/// Retrieve a given tensor from the workspace. If there is no such
/// a tensor, a null tensor is returned instead.
vl::Tensor Workspace::get(string name)
{
  // Search if such a tensor exists.
  auto const& found = tensors.find(name) ;
  if (found != tensors.end()) { return found->second ; }
  return Tensor() ; // Null tensor
}

/// Retrieve a tensor with specified type and shape from the workspace.
/// If no such a tensor is already found in the workspace,
/// a new one is allocated, possibly after deleting a previous tensor
/// of the same name (if any).
vl::Tensor Workspace::get(string name, DataType dt, TensorShape const& shape)
{
  // Search if such a tensor exists.
  auto const& found = tensors.find(name) ;
  if (found != tensors.end()) {
    auto& tensor = found->second ;
    if (tensor.getDataType() == dt && tensor == shape) {
      return tensor ;
    }
  }
  
  // No matching tensor found; create a new one.
  remove(name) ;
  size_t numBytes = shape.getNumElements() * getDataTypeSizeInBytes(dt) ;
  void* memory = malloc(numBytes) ;
  assert(memory) ;
  if (memory == NULL) {
    // Throw or return null tensor?
    numBytes = 0 ;
  }
  Tensor tensor(shape, dt, VLDT_CPU, memory, numBytes) ;

  // Add back to list.
  tensors[name] = tensor ;
  return tensor ;
}

void Workspace::remove(string name)
{
  // Search if such a tensor exists.
  auto const& found = tensors.find(name) ;
  if (found != tensors.end()) {
    auto& tensor = found->second ;
    free(tensor.getMemory()) ;
    tensors.erase(found) ;
  }
}

bool Workspace::exists(string name) const
{
  auto const& found = tensors.find(name) ;
  return (found != tensors.end()) ;
}

Workspace::~Workspace()
{
  for (auto x = tensors.begin() ; x != tensors.end() ; x = tensors.begin()) {
    remove(x->first) ;
  }
}

std::string const& Workspace::baseName() const
{
  return baseNameString ;
}

void Workspace::baseName(std::string const& name)
{
  baseNameString = name ;
}

void Workspace::inputName(std::string const& inputFile)
{
  inputFileName = inputFile ;
}

std::string const & Workspace::inputName() const
{
  return inputFileName ;
}

void Workspace::printMethod(int const & printMethod)
{
  method =  printMethod ;
}

int const & Workspace::printmethod() const
{
  return method ;
}

vl::Tensor & Workspace::getAverageColour(vl::DataType dt, vl::TensorShape const & shape)
{
  // Create a new one.
  size_t numBytes = shape.getNumElements() * getDataTypeSizeInBytes(dt) ;
  void* memory = malloc(numBytes) ;
  assert(memory) ;
  if (memory == NULL) {
    // Throw or return null tensor?
    numBytes = 0 ;
  }
  Tensor tensor(shape, dt, VLDT_CPU, memory, numBytes) ;

  averageColour = tensor ;
  
  return averageColour ;
}

vl::Tensor & Workspace::colour(){return averageColour;}

// Allocate class description in workspace
void Workspace::getDescription(int key, std::string substring )
{
  descriptions[key] = substring ;
}

// MARK: - Program

vl::ErrorCode Program::execute(Workspace& ws)
{
  // cout << "Executing load average colour of image" << endl ;
  PNCHECK(LoadMeta(ws)) ;
  
  for (auto const& op : source["operations"]) {
    auto type = op["type"].get<string>() ;
    cout << "Executing " << type << endl ;
    if (type == "Load") {
      PNCHECK(Load(op, ws)) ;
    }
    else if (type == "dagnn.Conv") {
      PNCHECK(Conv(op, ws)) ;
    }
    else if (type == "dagnn.Pooling") {
      PNCHECK(Pool(op, ws));
    }
    else if (type == "dagnn.ReLU") {
      PNCHECK(ReLU(op, ws)) ;
    }
    else if (type == "dagnn.LRN") {
      PNCHECK(Norm(op, ws)) ;
    }
    else if (type == "dagnn.DropOut") {
      PNCHECK(DropOut(op, ws)) ;
    }
    else if (type == "dagnn.SoftMax") {
      PNCHECK(SoftMax(op, ws)) ;
    }
    else if (type == "LoadImage") {
      PNCHECK(LoadImage(op, ws)) ;
    }
    else if (type == "release") {
      auto name = op["name"][0].get<string>() ;
      ws.remove(name) ;
    }
  }
  return VLE_Success ;
}

void Program::load(std::string fileName)
{
  // Open the JSON file describing the neural network.
  auto jsonFileName = fileName + "/net.json" ;
  auto jsonFile = ifstream(jsonFileName) ;
  if (!jsonFile.is_open()) {
    return ;
  }

  // Parse the JSON file.
  source.clear() ;
  jsonFile >> source ;

  // Todo: catch errors.
  
}

void Program::print() const
{
  cout << source.dump(4) << endl ;
}



