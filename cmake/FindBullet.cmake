include(CheckCXXSourceRuns)
include(CMakePushCheckState)
include(FindPackageHandleStandardArgs)
include(SelectLibraryConfigurations)

find_path(
	BULLET_INCLUDE_DIRS
	NAMES
	btBulletCollisionCommon.h
	PATH_SUFFIXES
	bullet
)

mark_as_advanced(BULLET_INCLUDE_DIRS)

find_library(
	BULLET_BULLETCOLLISION_LIBRARY_DEBUG
	NAMES
	BulletCollision-float64_Debug BulletCollision_Debug
)

find_library(
	BULLET_BULLETCOLLISION_LIBRARY_RELEASE
	NAMES
	BulletCollision-float64 BulletCollision
)

select_library_configurations(BULLET_BULLETCOLLISION)

find_library(
	BULLET_BULLETDYNAMICS_LIBRARY_DEBUG
	NAMES
	BulletDynamics-float64_Debug BulletDynamics_Debug
)

find_library(
	BULLET_BULLETDYNAMICS_LIBRARY_RELEASE
	NAMES
	BulletDynamics-float64 BulletDynamics
)

select_library_configurations(BULLET_BULLETDYNAMICS)

find_library(
	BULLET_BULLETSOFTBODY_LIBRARY_DEBUG
	NAMES
	BulletSoftBody-float64_Debug BulletSoftBody_Debug
)

find_library(
	BULLET_BULLETSOFTBODY_LIBRARY_RELEASE
	NAMES
	BulletSoftBody-float64 BulletSoftBody
)

select_library_configurations(BULLET_BULLETSOFTBODY)

find_library(
	BULLET_CONVEXDECOMPOSITION_LIBRARY_DEBUG
	NAMES
	ConvexDecomposition-float64_Debug ConvexDecomposition_Debug
)

find_library(
	BULLET_CONVEXDECOMPOSITION_LIBRARY_RELEASE
	NAMES
	ConvexDecomposition-float64 ConvexDecomposition
)

select_library_configurations(BULLET_CONVEXDECOMPOSITION)

find_library(
	BULLET_LINEARMATH_LIBRARY_DEBUG
	NAMES
	LinearMath-float64_Debug LinearMath_Debug
)

find_library(
	BULLET_LINEARMATH_LIBRARY_RELEASE
	NAMES
	LinearMath-float64 LinearMath
)

select_library_configurations(BULLET_LINEARMATH)

set(
	BULLET_LIBRARIES
	${BULLET_BULLETCOLLISION_LIBRARIES}
	${BULLET_BULLETDYNAMICS_LIBRARIES}
	${BULLET_BULLETSOFTBODY_LIBRARIES}
	${BULLET_LINEARMATH_LIBRARIES}
)

if(BULLET_INCLUDE_DIRS AND BULLET_LIBRARIES)
	cmake_push_check_state(RESET)
	set(CMAKE_REQUIRED_DEFINITIONS -DBT_USE_DOUBLE_PRECISION)
	set(CMAKE_REQUIRED_INCLUDES ${BULLET_INCLUDE_DIRS})
	set(CMAKE_REQUIRED_LIBRARIES ${BULLET_LIBRARIES})
	check_cxx_source_runs("
		#include <btBulletCollisionCommon.h>
		int main()
		{
			btVector3 boxHalfExtents(1, -2, 3);
			btBoxShape box(boxHalfExtents);
			btVector3 boxHalfExtentsWithMargin = box.getHalfExtentsWithMargin();
			return !btFuzzyZero(boxHalfExtents.distance(boxHalfExtentsWithMargin));
		}
	" _BULLET_DOUBLE_PRECISION)
	
	if(_BULLET_DOUBLE_PRECISION)
		set(BULLET_DEFINITIONS -DBT_USE_DOUBLE_PRECISION)
	endif()
	
	unset(_BULLET_DOUBLE_PRECISION)
	cmake_pop_check_state()
endif()

mark_as_advanced(BULLET_DEFINITIONS)

if(BULLET_INCLUDE_DIRS AND EXISTS "${BULLET_INCLUDE_DIRS}/LinearMath/btScalar.h")
	file(STRINGS "${BULLET_INCLUDE_DIRS}/LinearMath/btScalar.h" _BULLET_VERSION_DEFINE REGEX "#define[\t ]+BT_BULLET_VERSION[\t ]+[0-9]+.*")
	string(REGEX REPLACE "#define[\t ]+BT_BULLET_VERSION[\t ]+([0-9])[0-9][0-9].*" "\\1" BULLET_VERSION_MAJOR "${_BULLET_VERSION_DEFINE}")
	string(REGEX REPLACE "#define[\t ]+BT_BULLET_VERSION[\t ]+[0-9]([0-9][0-9]).*" "\\1" BULLET_VERSION_MINOR "${_BULLET_VERSION_DEFINE}")
	
	if(NOT BULLET_VERSION_MAJOR STREQUAL "" AND NOT BULLET_VERSION_MINOR STREQUAL "")
		set(BULLET_VERSION "${BULLET_VERSION_MAJOR}.${BULLET_VERSION_MINOR}")
	endif()
	
	unset(_BULLET_VERSION_DEFINE)
endif()

find_package_handle_standard_args(
	Bullet
	FOUND_VAR BULLET_FOUND
	REQUIRED_VARS BULLET_INCLUDE_DIRS BULLET_LIBRARIES
	VERSION_VAR BULLET_VERSION
)

if((BULLET_BULLETCOLLISION_LIBRARY_RELEASE OR BULLET_BULLETCOLLISION_LIBRARY_DEBUG) AND BULLET_INCLUDE_DIRS)
	set(BULLET_BULLETCOLLISION_LIBRARY_FOUND ON)
endif()

if((BULLET_BULLETDYNAMICS_LIBRARY_RELEASE OR BULLET_BULLETDYNAMICS_LIBRARY_DEBUG) AND BULLET_INCLUDE_DIRS)
	set(BULLET_BULLETDYNAMICS_LIBRARY_FOUND ON)
endif()

if((BULLET_BULLETSOFTBODY_LIBRARY_RELEASE OR BULLET_BULLETSOFTBODY_LIBRARY_DEBUG) AND BULLET_INCLUDE_DIRS)
	set(BULLET_BULLETSOFTBODY_LIBRARY_FOUND ON)
endif()

if((BULLET_CONVEXDECOMPOSITION_LIBRARY_RELEASE OR BULLET_CONVEXDECOMPOSITION_LIBRARY_DEBUG) AND BULLET_INCLUDE_DIRS)
	set(BULLET_CONVEXDECOMPOSITION_LIBRARY_FOUND ON)
endif()

if((BULLET_LINEARMATH_LIBRARY_RELEASE OR BULLET_LINEARMATH_LIBRARY_DEBUG) AND BULLET_INCLUDE_DIRS)
	set(BULLET_LINEARMATH_LIBRARY_FOUND ON)
endif()

if(BULLET_BULLETCOLLISION_LIBRARY_FOUND AND NOT TARGET Bullet::BulletCollision)
	add_library(Bullet::BulletCollision UNKNOWN IMPORTED)
	
	if(BULLET_BULLETCOLLISION_LIBRARY_RELEASE)
		set_property(TARGET Bullet::BulletCollision APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
		set_target_properties(Bullet::BulletCollision PROPERTIES IMPORTED_LOCATION_RELEASE "${BULLET_BULLETCOLLISION_LIBRARY_RELEASE}")
	endif()
	
	if(BULLET_BULLETCOLLISION_LIBRARY_DEBUG)
		set_property(TARGET Bullet::BulletCollision APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
		set_target_properties(Bullet::BulletCollision PROPERTIES IMPORTED_LOCATION_DEBUG "${BULLET_BULLETCOLLISION_LIBRARY_DEBUG}")
	endif()
	
	set_target_properties(
		Bullet::BulletCollision PROPERTIES
		INTERFACE_COMPILE_DEFINITIONS "${BULLET_DEFINITIONS}"
		INTERFACE_INCLUDE_DIRECTORIES "${BULLET_INCLUDE_DIRS}"
	)
endif()

if(BULLET_BULLETDYNAMICS_LIBRARY_FOUND AND NOT TARGET Bullet::BulletDynamics)
	add_library(Bullet::BulletDynamics UNKNOWN IMPORTED)
	
	if(BULLET_BULLETDYNAMICS_LIBRARY_RELEASE)
		set_property(TARGET Bullet::BulletDynamics APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
		set_target_properties(Bullet::BulletDynamics PROPERTIES IMPORTED_LOCATION_RELEASE "${BULLET_BULLETDYNAMICS_LIBRARY_RELEASE}")
	endif()
	
	if(BULLET_BULLETDYNAMICS_LIBRARY_DEBUG)
		set_property(TARGET Bullet::BulletDynamics APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
		set_target_properties(Bullet::BulletDynamics PROPERTIES IMPORTED_LOCATION_DEBUG "${BULLET_BULLETDYNAMICS_LIBRARY_DEBUG}")
	endif()
	
	set_target_properties(
		Bullet::BulletDynamics PROPERTIES
		INTERFACE_COMPILE_DEFINITIONS "${BULLET_DEFINITIONS}"
		INTERFACE_INCLUDE_DIRECTORIES "${BULLET_INCLUDE_DIRS}"
	)
endif()

if(BULLET_BULLETSOFTBODY_LIBRARY_FOUND AND NOT TARGET Bullet::BulletSoftBody)
	add_library(Bullet::BulletSoftBody UNKNOWN IMPORTED)
	
	if(BULLET_BULLETSOFTBODY_LIBRARY_RELEASE)
		set_property(TARGET Bullet::BulletSoftBody APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
		set_target_properties(Bullet::BulletSoftBody PROPERTIES IMPORTED_LOCATION_RELEASE "${BULLET_BULLETSOFTBODY_LIBRARY_RELEASE}")
	endif()
	
	if(BULLET_BULLETSOFTBODY_LIBRARY_DEBUG)
		set_property(TARGET Bullet::BulletSoftBody APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
		set_target_properties(Bullet::BulletSoftBody PROPERTIES IMPORTED_LOCATION_DEBUG "${BULLET_BULLETSOFTBODY_LIBRARY_DEBUG}")
	endif()
	
	set_target_properties(
		Bullet::BulletSoftBody PROPERTIES
		INTERFACE_COMPILE_DEFINITIONS "${BULLET_DEFINITIONS}"
		INTERFACE_INCLUDE_DIRECTORIES "${BULLET_INCLUDE_DIRS}"
	)
endif()

if(BULLET_CONVEXDECOMPOSITION_LIBRARY_FOUND AND NOT TARGET Bullet::ConvexDecomposition)
	add_library(Bullet::ConvexDecomposition UNKNOWN IMPORTED)
	
	if(BULLET_CONVEXDECOMPOSITION_LIBRARY_RELEASE)
		set_property(TARGET Bullet::ConvexDecomposition APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
		set_target_properties(Bullet::ConvexDecomposition PROPERTIES IMPORTED_LOCATION_RELEASE "${BULLET_CONVEXDECOMPOSITION_LIBRARY_RELEASE}")
	endif()
	
	if(BULLET_CONVEXDECOMPOSITION_LIBRARY_DEBUG)
		set_property(TARGET Bullet::ConvexDecomposition APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
		set_target_properties(Bullet::ConvexDecomposition PROPERTIES IMPORTED_LOCATION_DEBUG "${BULLET_CONVEXDECOMPOSITION_LIBRARY_DEBUG}")
	endif()
	
	set_target_properties(
		Bullet::ConvexDecomposition PROPERTIES
		INTERFACE_COMPILE_DEFINITIONS "${BULLET_DEFINITIONS}"
		INTERFACE_INCLUDE_DIRECTORIES "${BULLET_INCLUDE_DIRS}"
	)
endif()

if(BULLET_LINEARMATH_LIBRARY_FOUND AND NOT TARGET Bullet::LinearMath)
	add_library(Bullet::LinearMath UNKNOWN IMPORTED)
	
	if(BULLET_LINEARMATH_LIBRARY_RELEASE)
		set_property(TARGET Bullet::LinearMath APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
		set_target_properties(Bullet::LinearMath PROPERTIES IMPORTED_LOCATION_RELEASE "${BULLET_LINEARMATH_LIBRARY_RELEASE}")
	endif()
	
	if(BULLET_LINEARMATH_LIBRARY_DEBUG)
		set_property(TARGET Bullet::LinearMath APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
		set_target_properties(Bullet::LinearMath PROPERTIES IMPORTED_LOCATION_DEBUG "${BULLET_LINEARMATH_LIBRARY_DEBUG}")
	endif()
	
	set_target_properties(
		Bullet::LinearMath PROPERTIES
		INTERFACE_COMPILE_DEFINITIONS "${BULLET_DEFINITIONS}"
		INTERFACE_INCLUDE_DIRECTORIES "${BULLET_INCLUDE_DIRS}"
	)
endif()
