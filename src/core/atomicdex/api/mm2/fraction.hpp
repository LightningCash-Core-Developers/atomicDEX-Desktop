#pragma once

#include <string>

#include <nlohmann/json_fwd.hpp>
#include <entt/core/attribute.h>

namespace atomic_dex::mm2
{
    struct fraction
    {
        std::string denom;
        std::string numer;
    };

    ENTT_API void from_json(const nlohmann::json& j, fraction& fraction);
}