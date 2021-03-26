**Documentation of trade calibration**

Bilateral trade calibration is of vital importance for this study. In GLOBIOM, future trade flows are determined by commodity prices, trade costs. Trade costs include tariffs, transport costs, and a nonlinear trade expansion costs that reflect persistency in trade patterns. Tariffs and transport costs are kept same as base year. The trade expansion costs are used in GLOBIOM to represent the capacity constraints slowing down expansion of trade flows in the short term. They can be regarded as investments necessary to expand trading infrastructure. GLOBIOM allows for appearance of new trade flows, which were not observed in the base year. Exponential function represents the trade cost (1) when trade flows are observed in the base year, for new trade flows a quadratic trade cost function (2) is used:

Trade costs in period t are calculated with andreflecting the elasticity of trade costs to traded quantity in the respective equations. The intercept is equal to the tariff plus transport cost. The bilateral trade flows between China and other countries for 2010 were calibrated to match the FAO trade matrix statistics by manipulating the elasticities and intercepts in the trade cost equations. The bilateral trade validation of major commodities is shown in figure 1.

![](https://github.com/iiasa/virtual_trade/blob/main/images/calibration_results1.png)
![](https://github.com/iiasa/virtual_trade/blob/main/images/calibration_results2.png)

Figure 1. Trade calibration results for key agricultural commodities. The first column represents China&#39;s net import quantities, and the last three plots refer to imports from major trade partners.

**Documentation of virtual trade calculation**

Virtual trade flows refer to resources or pollution embodied in international trade. We focus our analysis on seven major exporting regions to China: Argentina, Australia, Brazil, Canada, New Zealand, the United States, and the European Union, which account for more than 80% of the value of China agricultural imports (Table 1).

Table 1. The import value (Billion US$) of agricultural products from main exporting regions. Data is derived from FAOSTAT ([http://www.fao.org/faostat/en/#data/TP](http://www.fao.org/faostat/en/#data/TP))

| Region | 2015 | 2016 | 2017 | Average | Share of total import value |
| --- | --- | --- | --- | --- | --- |
| Brazil | 21.1 | 20.8 | 25.7 | 22.5 | 30% |
| --- | --- | --- | --- | --- | --- |
| United States | 18.9 | 19.1 | 19.6 | 19.2 | 26% |
| Canada | 4.1 | 4.1 | 5.4 | 4.5 | 6% |
| EU | 4.4 | 4.5 | 3.8 | 4.2 | 6% |
| Argentina | 4.8 | 3.8 | 3.3 | 4.0 | 5% |
| Australia | 4.4 | 3.1 | 4.1 | 3.9 | 5% |
| New Zealand | 3.0 | 3.0 | 3.9 | 3.3 | 4% |
| Rest of world | 13.8 | 12.0 | 14.7 | 13.5 | 18% |

With respect to China trade flows, we also calculated the export effects, however, due to the imports are dominating overall trade pattern of China, we allocated the export impacts into domestic production side. To calculate trade impact, we assume that production for domestic consumption and export have the same domestic environmental impact. This is the assumption commonly used in many previous studies on virtual trade in water (Hoekstra and Hung, 2005), land (Würtenberger et al., 2006), and nitrogen (Huang et al., 2019). The environmental intensity in a resource for a specific product _P_ in exporting regions _R_ and specific year _T_ is defined as:

Where is the bilateral trade quantity of product exported to China from region in year . Bilateral trade volumes are here represented as net flows, as our framework rely on an homogenous good assumption (Takayama, T. and Judge, 1971) and hence a pair of trading partners will be always trading only in one direction at the same time. is in specific year , total production of product of exporting region . is total harvested area of product in exporting region . The market variables, bilateral trade quantity, land area and production quantities has been estimated based on FAOSTAT data.

Virtual nitrogen (N) and water calculations follow the same logic - see Equation 4 and 5 - where represents synthetic fertilizer use, and represents irrigation water use for product of exporting region . For nitrogen and irrigation water, we used crop-specific resource intensity informed by EPIC model calculations.

Equation 6 was used to calculate virtual agricultural related GHG emissions. Fertilizer nitrous oxide (N2O) emissions and methane (CH4) from rice paddies were considered as direct crop related GHG emissions. N2O was calculated based on N fertilizer consumption and IPCC emission coefficients (IPCC, 2006) and rice CH4 based on FAOSTAT average emission factors ([http://www.fao.org/fao-stat/en/#data/GR](http://www.fao.org/fao-stat/en/#data/GR)). For livestock products, we used emissions intensity parameters for CH4 and N2O from enteric fermentation, manure management, manure dropped on pastures, rangelands and paddocks, and manure management from the global livestock production systems database (Herrero et al., 2013).

Land use: Data on land type and land cover are based on GLC2000 ([https://forobs.jrc.ec.europa.eu/pr-oducts/glc2000/glc2000.php](https://forobs.jrc.ec.europa.eu/pr-oducts/glc2000/glc2000.php)) and are used in the following aggregate categories: Cropland, Other agricultural land, Pasture, Forest, Wetland, Other natural land, Not relevant land. In this study, we focus on agricultural land (Cropland and Pasture) and forest. Definition of pasture in GLOBIOM is where ruminants grazing is occurring which explains why pasture area differs from grassland statistics. The remaining grassland in GLOBIOM is included in other natural vegetation because it has more ecological function than agricultural use.

Nitrogen: The spatially explicit crop-specific fertilizer use comes from EPIC rescaled by FAOSTAT country values.

GHG: A dozen different GHG emissions sources related to agriculture and land use change are represented in GLOBIOM. All GHG emissions calculations in GLOBIOM are based on IPCC guidelines on GHG accounting (IPCC, 2006). The coefficients and sources can be found following table:

Table 2 GHG emissions in GLOBIOM

| Sector | Type | GHG | Source |
| --- | --- | --- | --- |
| Crop | Rice methane | CH4 | FAO average value |
| --- | --- | --- | --- |
| Crop | Synthetic fertilizer | N2O | IPCC coefficients (IPCC, 2006) |
| Crop | Organic Fertilizer | N2O | Herrero _et al._, 2013 |
| Livestock | Enteric fermentation | CH4 | Herrero _et al._, 2013 |
| Livestock | Manure management | CH4 | Herrero _et al._, 2013 |
| Livestock | Manure management | N2O | Herrero _et al._, 2013 |
| Livestock | Manure grassland | N2O | Herrero _et al._, 2013 |
| Land use change | Deforestation | CO2 | G4M model (G. Kindermann et al., 2008) |
| Land use change | Other natural land conversion | CO2 | Gibbs and Ruesch, 2008 |

Irrigation water use: Water availability was simulated with LPJmL a hydrological model (Gerten et al., 2004). Water demand is based on EPIC runs for different crops, and rescaled to country total irrigation water withdrawals in FAO AQUASTAT (FAO, 2016) to adjust for water use efficiency. And crop-specific irrigation area is derived from Spatial Production Allocation Model (Liu et al., 2013). More information can be referred to Sauer _et al._, 2010.

To calculate emissions from deforestation, we rely on a top-down indirect allocation approach (Sandström et al., 2018). We first determined forest losses in exporting regions based on the G4M model calculations (Georg Kindermann et al., 2008), and then assigned the deforestation attributable to cropland and pasture expansion based on Curtis et al. 2018. Then we allocated the cropland deforestation emissions to individual crops based on their contribution to the total cropland area expansion. The pasture related deforestation was distributed between ruminant products based on the pasture area necessary to cover the grass feed requirements of each livestock production system. Finally, we calculated the share of China&#39;s virtual land import within the total area of each agricultural product. The deforestation emissions related to crop or pasture are then calculated based on the following equations:

where and are deforestation emission caused by cropland and pasture expansion in region and year , respectively; only the expanded area is accounted for in ; indicates the virtual crop area embodied in trade, which is presented in equation (3) and divided by , to calculate the share of virtual land import. Similarly, deforestation caused by virtual pasture trade can be derived from equation (8).

Environmental impacts due to feed production are included in the virtual trade flows related to livestock products. For this purpose, we used the regional livestock production specific feed requirements from Herrero et al. 2013 Then we calculated the total use of feed for different livestock products and the related domestic environmental impacts and allocated them proportionally based on quantities of the bilateral trade to the environmental impacts imported by China. For feed crops embodied in the trade of livestock products, we took into account only locally produced feed. This may lead to minor underestimation of the overall impact of China&#39;s imports, but this should remain minor as many livestock products exporters to China are not major feed crop importers.

**Reference**

Curtis, P.G., Slay, C.M., Harris, N.L., Tyukavina, A., Hansen, M.C., 2018. Classifying drivers of global forest loss. Science (80-. ). 361, 1108–1111. https://doi.org/10.1126/science.aau3445

FAO, 2016. AQUASTAT Main Database [WWW Document]. AQUASTAT Main Database. URL http://www.fao.org/nr/water/aquastat/data/query/index.html?lang=en

Gerten, D., Schaphoff, S., Haberlandt, U., Lucht, W., Sitch, S., 2004. Terrestrial vegetation and water balance - Hydrological evaluation of a dynamic global vegetation model. J. Hydrol. 286. https://doi.org/10.1016/j.jhydrol.2003.09.029

Gibbs, H.K., Ruesch, A., 2008. New IPCC Tier-1 Global Biomass Carbon Map for the Year 2000. https://doi.org/10.15485/1463800

Herrero, M., Havlik, P., Valin, H., Notenbaert, A., Rufino, M.C., Thornton, P.K., Blummel, M., Weiss, F., Grace, D., Obersteiner, M., 2013. Biomass use, production, feed efficiencies, and greenhouse gas emissions from global livestock systems. Proc. Natl. Acad. Sci. 110, 20888–20893. https://doi.org/10.1073/pnas.1308149110

Hoekstra, A.Y., Hung, P.Q., 2005. Globalisation of water resources: International virtual water flows in relation to crop trade. Glob. Environ. Chang. 15, 45–56. https://doi.org/10.1016/j.gloenvcha.2004.06.004

Huang, G., Yao, G., Zhao, J., Lisk, M.D., Yu, C., Zhang, X., 2019. The environmental and socioeconomic trade-offs of importing crops to meet domestic food demand in China. Environ. Res. Lett. 14. https://doi.org/10.1088/1748-9326/ab3c10

IPCC, 2006. IPCC Guidelines for National Greenhouse Gas Inventories.

Kindermann, Georg, McCallum, I., Fritz, S., Obersteiner, M., 2008. A global forest growing stock, biomass and carbon map based on FAO statistics. Silva Fenn. 42, 387–396. https://doi.org/10.14214/sf.244

Kindermann, G., Obersteiner, M., Sohngen, B., Sathaye, J., Andrasko, K., Rametsteiner, E., Schlamadinger, B., Wunder, S., Beach, R., 2008. Global cost estimates of reducing carbon emissions through avoided deforestation. Proc. Natl. Acad. Sci. 105, 10302–10307. https://doi.org/10.1073/pnas.0710616105

Liu, Junguo, Zang, C., Tian, S., Liu, Jianguo, Yang, H., Jia, S., You, L., Liu, B., Zhang, M., 2013. Water conservancy projects in China: Achievements, challenges and way forward. Glob. Environ. Chang. 23, 633–643. https://doi.org/10.1016/j.gloenvcha.2013.02.002

Sandström, V., Valin, H., Krisztin, T., Havlík, P., Herrero, M., Kastner, T., 2018. The role of trade in the greenhouse gas footprints of EU diets. Glob. Food Sec. 19, 48–55. https://doi.org/10.1016/J.GFS.2018.08.007

Sauer, T., Havlík, P., Schneider, U.A., Schmid, E., Kindermann, G., Obersteiner, M., 2010. Agriculture and resource availability in a changing world: The role of irrigation. Water Resour. Res. 46, 1–12. https://doi.org/10.1029/2009WR007729

Takayama, T. and Judge, G.G., 1971. Spatial and temporal price allocation models. Amsterdam, North-Holland.

Würtenberger, L., Koellner, T., Binder, C.R., 2006. Virtual land use and agricultural trade: Estimating environmental and socio-economic impacts. Ecol. Econ. 57, 679–697. https://doi.org/10.1016/j.ecolecon.2005.06.004
