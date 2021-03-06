TEMPLATE = app
TARGET = omweathertest
DESTDIR = .
VPATH = ../core
INCLUDEPATH += ../core
CONFIG += link_pkgconfig
PKGCONFIG += libxml++-2.6 libcurl \
             QtCore \
             QtXml

#LIBS += -L ../core -lomweather-core
LIBS += -L ../core  ../core/libomweather-core.a
TEST_HEADERS += omweathertest.h
alltests.target = omweathertest.cpp
alltests.commands = cxxtestgen.pl --error-printer -o omweathertest.cpp $$TEST_HEADERS
alltests.depends = $$TEST_HEADERS
QMAKE_EXTRA_TARGETS += alltests
SOURCES += omweathertest.cpp 
HEADERS += omweathertest.h
QMAKE_CLEAN += $$TARGET omweathertest.cpp
