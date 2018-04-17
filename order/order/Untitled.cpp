//
//  optimal.cpp
//  exercises
//
//  Created by Andrea Vedaldi on 09/02/2018.
//  Copyright © 2018 av. All rights reserved.
//

#include <iostream>
#include <iomanip>
#include <vector>
#include <string>
#include <map>
#include <set>
#include <cassert>

// Undefine to skip memoization (slow).
#define MEMOIZATION

using namespace std ;

// -------------------------------------------------------------------
// MARK: - Helper functions
// -------------------------------------------------------------------

// Check if the container contains element x.
template<typename T> bool contains(vector<T> const &v, T const &x) {
  return end(v) != find(begin(v), end(v), x);
}

template<typename T> bool contains(set<T> const &s, T const &x) {
  return end(s) != s.find(x) ;
}

// Print the collection.
template<typename T> ostream& operator<<(ostream &os, vector<T*> const &v) {
  int n = 0 ;
  for (auto x : v) os << ((n++) ? " " : "") << *x ;
  return os ;
}

template<typename T> ostream& operator<<(ostream &os, set<T*> const &v) {
  int n = 0 ;
  for (auto x : v) os << ((n++) ? " " : "") << *x ;
  return os ;
}

// -------------------------------------------------------------------
// MARK: - Computational graph representation
// -------------------------------------------------------------------

struct Node
{
  template<class It>
  Node(It first, It last)
  : size(0), numUsages(0)
  {
    while (first != last) {
      inputs.push_back(*first) ;
      (*first)->outputs.push_back(this) ;
      (*first)->numUsages++ ;
      first++ ;
    }
  }

  Node(std::initializer_list<reference_wrapper<Node>> inputs)
  : size(0), numUsages(0)
  {
    for (auto input : inputs) {
      this->inputs.push_back(&input.get()) ;
      input.get().outputs.push_back(this) ;
      input.get().numUsages++ ;
    }
  }

  int size ;
  int numUsages ;
  string name ;
  vector<Node*> inputs ;
  vector<Node*> outputs ;
} ;

ostream& operator<< (ostream &os, Node const &x) {
  return os << x.name ;
}

// -------------------------------------------------------------------
// MARK: - Simulate a computation order
// -------------------------------------------------------------------

void simulate(vector<Node*> const& sequence) {
  int memory = 0 ;
  int maxMemory = 0 ;
  cout << "Simulated evaluation:" << endl ;
  for (auto node : sequence) {
    memory += node->size ;
    maxMemory = max(memory, maxMemory) ;
    cout << "  +" << setw(6) << *node << " (" << setw(3) << node->size << "): " << memory << endl ;
    for (auto parent : node->inputs) {
      parent->numUsages-- ;
      if (parent->numUsages == 0) {
        memory -= parent->size ;
        cout << "  -" << setw(6) << *parent << " (" << setw(3) << parent->size << "): " << memory << endl ;
      }
    }
  }
  cout << "  Maximum memory used: " << maxMemory << endl ;
}

// -------------------------------------------------------------------
// MARK: - Optimize the computation order
// -------------------------------------------------------------------

// The result of calling the optimization function.
struct result {int peak;  Node* node;} ;

// Check if two results are equivalent (used for debugging only).
bool operator==(result const&a, result const&b) {
  return (a.peak == b.peak) ;
}

int numCalls = 0 ;

map<set<Node*>, result> table ;

result xoptimize(set<Node*> &subgraph, vector<Node*> &open, int frontierSize, int pivotIndex)
{
  numCalls++ ;

  // Obtained S from S' by removing the PIVOT node v'.
  auto pivot = open[pivotIndex] ;
  subgraph.erase(subgraph.find(pivot)) ;
  open.erase(begin(open)+pivotIndex) ;

  // The PIVOT we have removed might have been part of the frontier; if so
  // subtract its size from the frontier size.
  if (pivot->numUsages < pivot->outputs.size()) { frontierSize -= pivot->size ; }

  // Removing the PIVOT can open more nodes and/or add them to the
  // frontier.
  for (auto y : pivot->inputs) {
    if (y->numUsages == y->outputs.size()) {
      frontierSize += y->size ;
    }
    y->numUsages-- ;
    if (y->numUsages == 0) {
      open.push_back(y) ;
    }
  }

  // Find the best next PIVOT (open node to remove).
  result optimal = {0,NULL};

#ifdef MEMOIZATION
  if (table.find(subgraph) != table.end()) {
    optimal = table[subgraph] ;
  } else
#endif
  {
    if (open.size() > 0) {
      optimal.peak =  numeric_limits<int>::max() ;
      for (int i = 0 ; i < open.size() ; ++i) {
        auto best = xoptimize(subgraph,open,frontierSize,i) ;
        if (optimal.peak > best.peak) {
          optimal.peak = best.peak ;
          optimal.node = open[i] ;
        }
      }
    }
    table[subgraph] = optimal ;
  }

  // Add the cost of computing the PIVOT v'.
  optimal.peak = max(optimal.peak, frontierSize + pivot->size) ;

  // Restore S' by adding v' back to S.
  for (auto y : pivot->inputs) { // Should be reversed, but it does not matter.
    if (y->numUsages == 0) {
      open.pop_back() ;
    }
    y->numUsages++ ;
  }
  open.insert(begin(open)+pivotIndex,pivot) ;
  subgraph.insert(pivot) ;
  return optimal ;
}

// Find all the nodes and open nodes in a graph starting from
// an overall (possibly fake) input.
void xvisit(Node* node, set<Node*> &subgraph, vector<Node*> &open)
{
  if (contains(subgraph,node)) return ;
  if (node->outputs.size() == 0) open.push_back(node) ;
  subgraph.insert(node) ;
  for (auto n : node->outputs) { xvisit(n,subgraph,open) ; }
}

pair<int, vector<Node*>> optimize(Node *source) {
  // Step 0: find all the nodes in the graph.
  set<Node*> subgraph ;
  vector<Node*> open ;
  xvisit(source,subgraph,open) ;

  // Step 1: add a fake skink node to get a single output.
  Node sink = Node(begin(open),end(open)) ;
  sink.name = "sink" ;
  sink.size = 0 ;
  open = {&sink} ;
  subgraph.insert(&sink) ;

  // Step 2: optmize recursively.
  table.clear() ;
  auto optimal = xoptimize(subgraph,open,0,0) ;
  table[subgraph].node = open[0] ;
  table[subgraph].peak = optimal.peak ;

  // Step 3: decode the optimal sequence found.
  vector<Node*> sequence ;
  auto node = open[0] ;
  while ((node = table[subgraph].node)) {
    subgraph.erase(node) ;
    sequence.push_back(node) ;
  }
  reverse(begin(sequence),end(sequence)) ;

  // Step 3: print the result.
  cout << "Contents of the table:" << endl ;
  for (auto row : table) {
    cout << "  |" << setw(4) << row.second.peak << "| <" << row.first << ">" << endl ;
  }
  cout << "Optimal execution order: <" << sequence << '>' << endl ;
  cout << "Optimal execution order cost: " << optimal.peak << endl ;
  cout << "Found in " << numCalls << " iterations" << endl ;
  simulate(sequence) ;
  return {optimal.peak, sequence} ;
}

// -------------------------------------------------------------------
// MARK: - Test driver
// -------------------------------------------------------------------

#define def(x,s,...) \
Node x{{__VA_ARGS__}} ; x.size = s ; x.name = #x

int main(int argc,char**argv)
{
#if 1
  {
    // Best: 131
    def(a,1) ;
    def(b,100,a) ;
    def(c,110,a) ;
    def(e,20,c) ;
    def(last,1,b,e) ;
    optimize(&a) ;
  }
#endif

#if 1
  {
    // Best: 131
    def(a,1) ;
    def(b,100,a) ;
    def(c,110,a) ;
    def(d,5,b) ;
    def(e,20,c) ;
    def(last,1,d,e) ;
    optimize(&a) ;
  }
#endif

#if 1
  {
    // Best: 130
    def(a,1) ;
    def(b,100,a) ;
    def(c,100,a) ;
    def(d,10,b) ;
    def(e,20,c) ;
    def(f,1,d,e) ;
    def(g,100,f) ;
    def(h,100,f) ;
    def(i,10,g) ;
    def(j,20,h) ;
    def(k,1,i,j) ;
    optimize(&a) ;
  }
#endif

#if 1
  {
    // Best: 131
    def(x1,1) ;
    def(x2,100,x1) ;
    def(x3,110,x1) ;
    def(x4,10,x2) ;
    def(x5,20,x3) ;
    def(x6,1,x4,x5) ;
    def(x7,100,x6) ;
    def(x8,110,x6) ;
    def(x10,10,x7) ;
    def(x9,20,x8) ;
    def(x11,1,x9,x10) ;
    optimize(&x1) ;
  }
#endif

#if 1
  {
    // Best: 6
    def(src,0);
    def(x1,10,src) ;
    def(x7,10,src) ;
    def(x2,130,x1) ;
    def(x3,110,x1) ;
    def(x4,10,x2) ;
    def(x5,40,x3) ;
    def(x6,1,x4,x5) ;
    def(x8,110,x3,x7) ;
    def(x9,130,x2,x7) ;
    def(x10,10,x1,x8) ;
    def(x11,10,x1,x9) ;
    def(x12,20,x10,x11) ;
    optimize(&src) ;
  }
#endif

  return 0;
}
