##########################################################################
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
# http://www.boost.org/LICENSE_1_0.txt                                   #
##########################################################################

set(_boost_component_table
  #component        CMake package name    version
  accumulators      BoostAccumulators     ""
  algorithm         BoostAlgorithm        ""
  any               BoostAny              ""
  array             BoostArray            ""
  asio              BoostAsio             ""
  assign            BoostAssign           ""
  auto_index        BoostAutoIndex        ""
  bcp               BoostBCP              ""
  bimap             BoostBimap            ""
  bind              BoostBind             ""
  boostbook         Boostbook             ""
  build             BoostBuild            ""
  chrono            BoostChrono           ""
  circular_buffer   BoostCircularBuffer   ""
  cmake             BoostCMake            ""
  compatibility     BoostCompatibility    ""
  concept_check     BoostConceptCheck     ""
  config            BoostConfig           ""
  container         BoostContainer        ""
  conversion        BoostConversion       ""
  core              BoostCore             ""
  crc               BoostCRC              ""
  date_time         BoostDateTime         ""
  detail            BoostDetail           ""
  disjoint_sets     BoostDisjointSets     ""
  dynamic_bitset    BoostDynamicBitset    ""
  exception         BoostException        ""
  filesystem        BoostFilesystem       ""
  flyweight         BoostFlyweight        ""
  foreach           BoostForeach          ""
  format            BoostFormat           ""
  function          BoostFunction         ""
  functional        BoostFunctional       ""
  function_types    BoostFunctionTypes    ""
  fusion            BoostFusion           ""
  geometry          BoostGeometry         ""
  gil               BoostGIL              ""
  graph             BoostGraph            ""
  graph_parallel    BoostGraphParallel    ""
  icl               BoostICL              ""
  inspect           BoostInspect          ""
  integer           BoostInteger          ""
  interprocess      BoostInterprocess     ""
  intrusive         BoostIntrusive        ""
  io                BoostIO               ""
  iostreams         BoostIOStreams        ""
  iterator          BoostIterator         ""
  lambda            BoostLambda           ""
  litre             BoostLitre            ""
  locale            BoostLocale           ""
  logic             BoostLogic            ""
  math              BoostMath             ""
  move              BoostMove             ""
  mpi               BoostMPI              ""
  mpl               BoostMPL              ""
  msm               BoostMSM              ""
  multi_array       BoostMultiArray       ""
  multi_index       BoostMultiIndex       ""
  numeric           BoostNumeric          ""
  optional          BoostOptional         ""
  parameter         BoostParameter        ""
  phoenix           BoostPhoenix          ""
  polygon           BoostPolygon          ""
  pool              BoostPool             ""
  preprocessor      BoostPreprocessor     ""
  program_options   BoostProgramOptions   ""
  property_map      BoostPropertyMap      ""
  property_tree     BoostPropertyTree     ""
  proto             BoostProto            ""
  ptr_container     BoostPtrContainer     ""
  python            BoostPython           ""
  quickbook         Quickbook             ""
  random            BoostRandom           ""
  range             BoostRange            ""
  ratio             BoostRatio            ""
  rational          BoostRational         ""
  regex             BoostRegex            ""
  scope_exit        BoostScopeExit        ""
  serialization     BoostSerialization    ""
  signals           BoostSignals          ""
  signals2          BoostSignals2         ""
  smart_ptr         BoostSmartPtr         ""
  spirit            BoostSpirit           ""
  statechart        BoostStatechart       ""
  static_assert     BoostStaticAssert     ""
  system            BoostSystem           ""
  test              BoostTest             ""
  thread            BoostThread           ""
  timer             BoostTimer            ""
  tokenizer         BoostTokenizer        ""
  tr1               BoostTR1              ""
  tti               BoostTTI              ""
  tuple             BoostTuple            ""
  typeof            BoostTypeof           ""
  type_traits       BoostTypeTraits       ""
  units             BoostUnits            ""
  unordered         BoostUnordered        ""
  utility           BoostUtility          ""
  uuid              BoostUUID             ""
  variant           BoostVariant          ""
  wave              BoostWave             ""
  xpressive         BoostXpressive        ""
  )

set(Boost_DEFINITIONS)
set(Boost_INCLUDE_DIRS)
set(Boost_LIBRARIES)
set(Boost_MODULE_PATH)

foreach(component ${Boost_FIND_COMPONENTS})
  list(FIND _boost_component_table ${component} index)
  if(index EQUAL "-1")
    message(WARNING "unknown Boost component: ${component}")
  else()
    math(EXPR package_index "${index} + 1")
    math(EXPR version_index "${index} + 2")
    list(GET _boost_component_table ${package_index} package)
    list(GET _boost_component_table ${version_index} version)
    find_package(${package} ${version} REQUIRED)
    list(APPEND Boost_DEFINITIONS ${package}_DEFINITIONS)
    list(APPEND Boost_INCLUDE_DIRS ${package}_INCLUDE_DIRS)
    list(APPEND Boost_LIBRARIES ${package}_LIBRARIES)
    list(APPEND Boost_MODULE_PATH ${package}_MODULE_PATH)
  endif()
endforeach(component)

set(Boost_USE_FILE "${CMAKE_CURRENT_LIST_DIR}/modules/UseBoost.cmake")
set(Boost_DEV_FILE "${CMAKE_CURRENT_LIST_DIR}/modules/UseBoostDev.cmake")
