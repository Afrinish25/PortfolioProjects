SELECT *
FROM PortfolioProject..CovidDeaths
order by 3,4

SELECT Location,date,total_cases, new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
order by 1,2

-- total case v total deaths
SELECT Location,MAX(CAST(total_deaths AS int) ) As maxdeaths
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Group by Location
order by maxdeaths DESC

--percentage of covid vax
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


--using a CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- temp table

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

 insert into #PercentPopulationVaccinated
 Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--view for visualization
Create view PercentPopulationVaccinated as
 Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not null

CREATE view total_vac as
SELECT location,MAX(convert(bigint,total_vaccinations)) as totalvax
FROM PortfolioProject..CovidVaccinations
WHERE total_vaccinations is not null
group by location


