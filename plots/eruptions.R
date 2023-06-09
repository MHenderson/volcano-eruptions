library(here)
library(readr)
library(sf)
library(tidyverse)
library(rnaturalearth)
library(rnaturalearthdata)

eruptions <- read_csv(here("data-raw", "eruptions.csv"))

eruptions_sf <- eruptions %>%
  st_as_sf(
    coords = c("longitude", "latitude"),
    crs = 4326,
    agr = "constant"
  )

world <- ne_countries(
  scale = "medium",
  returnclass = "sf"
) %>%
  filter(sovereignt != "Antarctica")

eruptions_to_plot <- eruptions_sf %>%
  filter(start_year >= 1900) %>%
  filter(start_year <= 1999) %>%
  filter(vei >= 4) %>%
  arrange(desc(vei))

eruptions_to_plot %>%
  ggplot() +
  geom_sf(data = world, alpha = .5, size = .2, fill = "chartreuse") +
  geom_sf(aes(size = vei), alpha = .5, colour = "red") +
  geom_sf_label(aes(label = volcano_name), data = eruptions_to_plot %>% head(n = 10), nudge_y = 5) +
  theme_bw() +
  labs(
    x        = "",
    y        = "",
    title    = "Large Volcano Eruptions 1900 to 1999",
    subtitle = "(all eruptions with vei > 4)",
    caption  = "data from The Smithsonian Institution (https://volcano.si.edu/)"
  ) +
  theme(
    panel.background = element_rect(
      fill     = "deepskyblue3",
      colour   = "deepskyblue3",
      size     = 0.5,
      linetype = "solid"
    ),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
  )

ggsave(here("plots", "eruptions.png"))
