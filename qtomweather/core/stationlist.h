#ifndef STATIONLIST_H
#define STATIONLIST_H
////////////////////////////////////////////////////////////////////////////////
#include <vector>
#include <string>
class Station;
#include "station.h"
#include "abstractconfig.h"
////////////////////////////////////////////////////////////////////////////////
namespace Core {
////////////////////////////////////////////////////////////////////////////////
    class StationList : public std::vector<Station*>, AbstractConfig {
        public:
            StationList();
    };
////////////////////////////////////////////////////////////////////////////////
} // namespace Core
////////////////////////////////////////////////////////////////////////////////
#endif // STATIONLIST_H