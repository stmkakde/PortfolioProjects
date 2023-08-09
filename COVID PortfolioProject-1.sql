--check if data is correctly imported
Select *
From [Portfolio Project]..CovidDeaths
Order by 3,4

Select * 
From [Portfolio Project]..CovidVaccination
Order by 3,4


--Select data for further use
Select location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths
Order by 1,2

-- total cases vs total deaths
-- DeathPercentage of India
-- Shows likelihood of dying if you live in India
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathPercenatge
From [Portfolio Project]..CovidDeaths 
Where location like 'India'
Order by 1,2


-- total cases vs population
-- Shiws what percentage of population got covid in India
Select location, date, total_cases, population, (total_cases/population)*100 As InfectionPercentage
From [Portfolio Project]..CovidDeaths 
Where location like 'India'
Order by 1,2


-- Countries and their highest InfectionPercentage registered
Select location, population, Max(total_cases) As HighestInfectionCount,
Max((total_cases/population))*100 As InfectionPercentage 
From [Portfolio Project]..CovidDeaths 
Group by location, population
Order by InfectionPercentage desc


-- Countries and their total death count
Select location, Max(Cast(total_deaths As int)) As TotalDeathCount
From [Portfolio Project]..CovidDeaths
Where continent is not null 
Group by location
Order by TotalDeathCount desc


--Continents and their total death count
Select location, Max(Cast(total_deaths As int)) As TotalDeathCount
From [Portfolio Project]..CovidDeaths
Where continent is  null 
Group by location
Order by TotalDeathCount desc


-- Daily numbers around the world
Select date, Sum(new_cases) As GloballyNewCases, Sum(Cast(new_deaths as int))
As GloballyNewDeaths, Sum(Cast(new_deaths as int))/Sum(new_cases)*100 As DeathPercentage
From [Portfolio Project]..CovidDeaths
Where continent is not null 
Group by date 
Order by date


 -- Globally final numbers as per available data
 Select Sum(new_cases) As GloballyTotalCases, Sum(Cast(new_deaths as int))
As GloballyTotalDeaths, Sum(Cast(new_deaths as int))/Sum(new_cases)*100 As FinalDeathPercentage
From [Portfolio Project]..CovidDeaths
Where continent is not null 


-- Join, Partition by
-- People vaccinated till date in a country
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
, Sum(Cast(vac.new_vaccinations as int)) Over (Partition by dea.location
Order by dea.location, dea.date) As PeopleVaccinatedTillDate
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccination vac
     On dea.location=vac.location and dea.date=vac.date
Where dea.continent is not null
Order by 2,3


-- Join, Partition by
-- India's vaccination data (date vs vaccinations)
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
, Sum(Cast(vac.new_vaccinations as int)) Over (Partition by dea.location
Order by dea.location, dea.date) As PeopleVaccinatedTillDate
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccination vac
     On dea.location=vac.location and dea.date=vac.date
Where dea.continent is not null and dea.location like 'India'
Order by 2,3


-- USING CTE-COMMON TABLE EXPRESSION
-- India and its vaccination percentage
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations
, PeopleVaccinatedTillDate)
As
(
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
, Sum(Cast(vac.new_vaccinations as int)) Over (Partition by dea.location
Order by dea.location, dea.date) As PeopleVaccinatedTillDate
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccination vac
     On dea.location=vac.location and dea.date=vac.date
Where dea.continent is not null and dea.location like 'India'
--Order by 2,3
)

Select *, (PeopleVaccinatedTillDate/Population)*100 As PerecentagePeopleVaccinated
From PopvsVac



-- USING TEMP TABLE 
-- #PercentPeopleVaccinated in INDIA

 Drop Table if exists #PercentPeopleVaccinated
Create Table #PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
PeopleVaccinatedTillDate numeric
)
Insert into #PercentPeopleVaccinated
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
, Sum(Cast(vac.new_vaccinations as int)) Over (Partition by dea.location
Order by dea.location, dea.date) As PeopleVaccinatedTillDate
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccination vac
     On dea.location=vac.location and dea.date=vac.date
Where dea.continent is not null and dea.location like 'India'
--Order by 2,3

Select *, (PeopleVaccinatedTillDate/Population)*100 As PerecentagePeopleVaccinated
From #PercentPeopleVaccinated




-- Creating view  to store data for later visualizations

Create View PercentPeopleVaccinated As 
Select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
, Sum(Cast(vac.new_vaccinations as int)) Over (Partition by dea.location
Order by dea.location, dea.date) As PeopleVaccinatedTillDate
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccination vac
     On dea.location=vac.location and dea.date=vac.date
Where dea.continent is not null and dea.location like 'India'
--Order by 2,3