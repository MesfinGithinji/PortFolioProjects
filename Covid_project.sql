 --select data to be used
Select Location, date, total_cases, new_cases, total_deaths, population
From PortFolioProject..CovidDeaths$
order by 1,2



--Taking a Look at Total Cases vs Total Deaths (how many people who were actually diagnosed,passed away?)
Select Location, date, total_cases, total_deaths ,(total_deaths/total_cases)*100 as Death_Percentage
From PortFolioProject..CovidDeaths$
Where location like '%Kenya%'
order by 1,2

--#1
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortFolioProject..CovidDeaths$
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

--Comparing Total Cases reported vs Population (what percentage of the population got infected)
Select Location, date,  population ,total_cases, (total_cases/population)*100 as Infection_PercentageRate
From PortFolioProject..CovidDeaths$
Where location like '%Kenya%'
order by 1,2


--which countires have the highest infection rate compared to population
Select Location, population ,max(total_cases) as HighestInfectionCount, max((total_cases/population)) *100 as Infection_PercentageRate
From PortFolioProject..CovidDeaths$
where continent is not null
Group by location , population 
order by Infection_PercentageRate desc

--#2
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortFolioProject..CovidDeaths$
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

--which countries had the highest death count per population
Select Location, max(cast(total_deaths as int)) as Total_Death_Count
From PortFolioProject..CovidDeaths$
where continent is not null
Group by location  
order by Total_Death_Count desc

--#3
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortFolioProject..CovidDeaths$
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

--#4
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortFolioProject..CovidDeaths$
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc



-- Death count per continent
Select location, max(cast(total_deaths as int)) as Total_Death_Count
From PortFolioProject..CovidDeaths$
where continent is null
Group by location  
order by Total_Death_Count desc


--Query to determine worldwide reported cases and deaths per day
Select date ,SUM(new_cases) as Total_WorldWide_DailyCases , SUM(cast(new_deaths as int)) as Total_WorldWide_deaths ,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_Percentage
From PortFolioProject..CovidDeaths$
where continent is not null
Group by date  
order by 1,2

--Query for the global numbers
Select SUM(new_cases) as Total_WorldWide_DailyCases , SUM(cast(new_deaths as int)) as Total_WorldWide_deaths ,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_Percentage
From PortFolioProject..CovidDeaths$
where continent is not null  
order by 1,2


--Query to Join the CovidDeaths Table & the CovidVaccinations Table
Select *
From PortFolioProject..CovidDeaths$ dea
Join PortFolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date 


--Query to determine the number of vaccinated people vs the total population per country , per continent
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
From PortFolioProject..CovidDeaths$ dea
Join PortFolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null 
order by 2,3

--Query to do a rolling count of the number of new vaccinations per country ,per continent
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as countof_vaccination
From PortFolioProject..CovidDeaths$ dea
Join PortFolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null 
order by 2,3


--Query to create a CTE
with PpltnVsVcntn (continent, location, date, population, new_vaccinations, countof_vaccination)
as
(
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as countof_vaccination
	From PortFolioProject..CovidDeaths$ dea
	Join PortFolioProject..CovidVaccinations$ vac
		On dea.location = vac.location
		and dea.date = vac.date 
	where dea.continent is not null 
	--order by 2,3
) 
	select *,(countof_vaccination/population)*100 as PrcntgVaccinationCount
	From PpltnVsVcntn 



--Query to create a Temp Table
Drop Table if exists #PrcntgPpltnVaccinated
Create Table #PrcntgPpltnVaccinated
(
	continent nvarchar(255),
	location  nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	vaccination_count numeric
)
Insert into #PrcntgPpltnVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as vaccination_count
	From PortFolioProject..CovidDeaths$ dea
	Join PortFolioProject..CovidVaccinations$ vac
		On dea.location = vac.location
		and dea.date = vac.date 
	where dea.continent is not null 
	--order by 2,3
select *,(vaccination_count/population)*100 as PcntgVcntnCount
	From #PrcntgPpltnVaccinated




--Creating the Necessary Views
Create View Population_VaccinatedPercentage as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as vaccination_count
	From PortFolioProject..CovidDeaths$ dea
	Join PortFolioProject..CovidVaccinations$ vac
		On dea.location = vac.location
		and dea.date = vac.date 
	where dea.continent is not null 
	--order by 2,3

