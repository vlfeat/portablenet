////
////  optimal.cpp
////  exercises
////
////  Created by Andrea Vedaldi on 09/02/2018.
////  Copyright © 2018 av. All rights reserved.
////
//
//#include <iostream>
//#include <vector>
//#include <string>
//#include <map>
//#include <set>
//#include <cassert>
//
//// Undefine to skip memoization (slow).
//#define MEMOIZATION
//
//using namespace std ;
//
//// -------------------------------------------------------------------
//// MARK: - Helper functions
//// -------------------------------------------------------------------
//
//// Check if the container contains element x.
//template<typename T> bool contains(vector<T> const &v, T const &x) {
//  return end(v) != find(begin(v), end(v), x);
//}
//
//template<typename T> bool contains(set<T> const &s, T const &x) {
//  return end(s) != s.find(x) ;
//}
//
//// Print collection.
//template<typename T> ostream& operator<<(ostream &os, vector<T*> const &v) {
//  for (auto x : v) os << *x << " "  ;
//  return os ;
//}
//
//template<typename T> ostream& operator<<(ostream &os, set<T*> const &v) {
//  for (auto x : v) os << *x << " "  ;
//  return os ;
//}
//
//// -------------------------------------------------------------------
//// MARK: - Computational graph representation
//// -------------------------------------------------------------------
//
//struct Node
//{
//  Node(std::initializer_list<reference_wrapper<Node>> inputs)
//  : size(0), numUsages(0)
//  {
//    for (auto input : inputs) {
//      this->inputs.push_back(&input.get()) ;
//      input.get().outputs.push_back(this) ;
//      input.get().numUsages++ ;
//    }
//  }
//
//  int size ;
//  int numUsages ;
//  string name ;
//  vector<Node*> inputs ;
//  vector<Node*> outputs ;
//} ;
//
//ostream& operator<< (ostream &os, Node const &x) {
//  return os << x.name ;
//}
//
//// -------------------------------------------------------------------
//// MARK: - Optimal graph ordering computation
//// -------------------------------------------------------------------
//
//// The result of calling the optimization function.
//struct result {int peak; int frontieerSize; Node* node ;} ;
//
//// Check if two results are equivalent (used for debugging only).
//bool operator==(result const&a, result const&b) {
//  return (a.peak == b.peak) && (a.frontieerSize == b.frontieerSize) ;
//}
//
//int numCalls = 0 ;
//
//map<set<Node*>, result> table ;
//
//result xoptimize(set<Node*> &subgraph, vector<Node*> &frontieer)
//{
//  numCalls++ ;
//
//#ifdef MEMOIZATION
//  if (table.find(subgraph) != table.end()) return table[subgraph] ;
//#endif
//
//  if (frontieer.size() == 0) {
//    return {0,0,NULL} ;
//  }
//
//  result optimal { numeric_limits<int>::max(), 0, NULL } ;
//  for (int i = 0 ; i < frontieer.size() ; ++i) {
//    // Delete each node in the frontieer in turn and make it our
//    // PIVOT node.
//    auto pivot = frontieer[i] ;
//    frontieer.erase(begin(frontieer)+i) ;
//    subgraph.erase(subgraph.find(pivot)) ;
//
//    // Deleting a node from the frontieer may cause other node
//    // to become part of it (as they are output nodes of the new
//    // subgraph). Find them.
//    for (auto y : pivot->inputs) {
//      y->numUsages-- ;
//      if (y->numUsages == 0) {
//        frontieer.push_back(y) ;
//      }
//    }
//
//    // Recursively optimize the subgraph.
//    auto best = xoptimize(subgraph,frontieer) ;
//
//    // The peak memory utilization is the maximum between
//    // the memory used to compute the subgraph and the memory
//    // used to compute the PIVOT. The latter is given by the
//    // size of the frontieer of the subgraph (which are its
//    // outoput nodes) plus the size of the PIVOT.
//    int frontieerSize = best.frontieerSize + pivot->size ;
//    int peak = max(best.peak, frontieerSize) ;
//
//    // Check if the solution we just obtained is better than the
//    // other ones so far. If so, store this as the ad-interim
//    // optimal move.
//    if (peak < optimal.peak) {
//      // Estimate the size of the frontieer of the complete
//      // graph (subgraph plus PIVOT). This is the same as
//      // the size of the subgraph frontier plus the PIVOT minus
//      // any frontieer nodes that were added above by deleting
//      // the PIVOT.
//      for (auto y : frontieer) {
//        if (contains(pivot->inputs, y)) { frontieerSize -= y->size ; }
//      }
//      optimal.peak = peak ;
//      optimal.frontieerSize = frontieerSize ;
//      optimal.node = pivot ;
//    }
//
//    // Undo the deletion of the PIVOT so that we can try another one.
//    for (auto y : pivot->inputs) { // Should be reversed, but it does not matter?
//      if (y->numUsages == 0) {
//        frontieer.pop_back() ;
//      }
//      y->numUsages++ ;
//    }
//    frontieer.insert(begin(frontieer)+i,pivot) ;
//    subgraph.insert(pivot) ;
//  }
//
//  // For debugging purposes, it does anything only if memoizatino is off.
//  if (table.find(subgraph) != table.end()) {
//    cout << "<duplicate> " ;
//    assert(table[subgraph] == optimal) ;
//  }
//
//  // Add the newly-found optimal partial solution to the table.
//  table[subgraph] = optimal ;
//
//  cout << "Inserted: " << subgraph << table[subgraph].peak << endl ;
//  return optimal ;
//}
//
//// Visit the graph staring from a certain node and find all
//// the graph nodes and its frontieer (output nodes).
//void xvisit(Node* node, set<Node*> &subgraph, vector<Node*> &frontieer)
//{
//  if (contains(subgraph,node)) return ;
//  if (node->outputs.size() == 0) frontieer.push_back(node) ;
//  subgraph.insert(node) ;
//  for (auto n : node->outputs) { xvisit(n,subgraph,frontieer) ; }
//}
//
//pair<int, vector<Node*>> optimize(Node *source) {
//  // Step 1: find all nodes in the graph.
//  set<Node*> subgraph ;
//  vector<Node*> frontieer ;
//  xvisit(source,subgraph,frontieer) ;
//
//  // Step 2: optmize recursively.
//  table.clear() ;
//  auto optimal = xoptimize(subgraph,frontieer) ;
//
//  // Step 3: decode the optimal sequence found.
//  vector<Node*> sequence ;
//  while (!subgraph.empty()) {
//    auto node = table[subgraph].node ;
//    sequence.push_back(node) ;
//    subgraph.erase(node) ;
//  }
//  reverse(begin(sequence),end(sequence)) ;
//
//  // Step 3: print the result.
//  cout << "Table contents:" << endl ;
//  for (auto row : table) {
//    cout << row.first << row.second.peak << endl ;
//  }
//  cout << "Optimal execution order: " << sequence << endl ;
//  cout << "Optimal execution order cost: " << optimal.peak << endl ;
//  cout << "Found in " << numCalls << " iterations" << endl ;
//  return {optimal.peak, sequence} ;
//}
//
//// -------------------------------------------------------------------
//// MARK: - Test driver
//// -------------------------------------------------------------------
//
//#define def(x,s,...) \
//Node x{{__VA_ARGS__}} ; x.size = s ; x.name = #x
//
//int main(int argc,char**argv)
//{
//#if 0
//  // Best: 130
//  def(a,1) ;
//  def(b,100,a) ;
//  def(c,100,a) ;
//  def(d,10,b) ;
//  def(e,20,c) ;
//  def(last,1,d,e) ;
//  set<Node*> nodes {&a,&b,&c,&d,&e,&last} ;
//  vector<Node*> frontieer {&last} ;
//#endif
//
//  // Best: 130
////  def(a,10) ;
////  def(b,130,a) ;
////  def(c,110,a) ;
////  def(d,10,b) ;
////  def(e,40,c) ;
////  def(f,1,d,e) ;
////  def(g,110,f) ;
////  def(h,60,f) ;
////  def(i,10,g) ;
////  def(j,80,h) ;
////  def(k,1,i,j) ;
//
//  def(a,10) ;
//  def(b,130,a) ;
//  def(c,110,a) ;
//  def(d,10,b) ;
//  def(e,40,c) ;
//  def(f,1,d,e) ;
//  def(df,1) ;
//  def(de,40,df,c) ;
////  def(dd,10,df,b) ;
////  def(dc,110,de,a) ;
////  def(db,130,dd,a) ;
////  def(da,10,db,dc) ;
//
//  optimize(&a) ;
//  return 0;
//}

