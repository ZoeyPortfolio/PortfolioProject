select *
From PortfolioProject.dbo.coviddeaths
Where continent is not null
order by 3, 4

-- select data that I'm going to be starting with
Select location, date, total_cases, new_cases, total_deaths, new_deaths
From PortfolioProject..coviddeaths
where continent is not null
order by 1,2



-- total cases vs total deaths
-- the likelihood of dying if people contract covid in Canada

Select location, date, (total_deaths / total_cases)*100 as percentdeath
From PortfolioProject..coviddeaths
where continent is not null
and location = 'Canada'
order by 1,2 

-- We can see the likelihood of dying after contracting reached to the highest in May 29th, 2020 which is around 8.56. After that, it starts to decline. 
-- Until now, the likelihood of dying falls to around 1.513. 


-- To see if the decreasing death rate is related to vaccination
select location, date, total_vaccinations
From PortfolioProject.dbo.covidvaccine
where location = 'Canada'
order by 1, 2 

-- We can see that the first vaccination in Canada starts from December 14th, 2020 and number of vaccinations have increased each day since than. 
-- Thus, we can say vaccination can be one factor that lowers the death rate. However, there may also other factors influences death rate simutaneously.



-- total cases vs total population
-- the percentage of population infected with covid
select location, date, total_cases, population, (total_cases / population) as infectedpopulation
From PortfolioProject..coviddeaths
where continent is not null
and location = 'Canada'
order by 1, 2

-- We can see the percentage of population being infected with covid in Canada fluctutated a lot at the beginning and
-- reached the highest amount 9.67 on March 25, 2020. 
-- Since that, the percentage has decreased a lot. 



-- countries with highest infection rate compared to population
select location, population, MAX((total_cases / population)*100) as highestinfectedpopulation
From PortfolioProject..coviddeaths
Group by location, population
order by highestinfectedpopulation desc

-- The country with highest infection rate per population is Andorra 



-- Countries with highest death count per population 
Select Location, MAX((total_cases / population)*100) as deathperpop
From PortfolioProject..coviddeaths
where continent is not null
Group by location
order by deathperpop desc

-- Now we can see the United States no longer has the highest death count per population. The country
-- with highest death per population is Andorra.


-- Breaking things down by continent

-- showing continent with the highest death count per population

Select continent, MAX((total_cases / population)*100) as deathperpop
From PortfolioProject..coviddeaths
where continent is not null
Group by continent
order by deathperpop desc

-- Until December 2021, Europe becomes the continent with highest death count per population


-- Global numbers

select continent, SUM(new_cases) as casescount, SUM(cast(new_deaths as int)) as deathscount
From PortfolioProject..coviddeaths
where continent is not null
group by continent
order by 2 desc,3 desc

-- Until December 2021, Europe has highest total new cases and total new deaths


Select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) as deathpercentage
From PortfolioProject..coviddeaths
where continent is not null
order by 1,2 

-- Until December 2021, total new cases in the world is 279355537 and total new deaths in the world is 5376040¡£
-- Death percentage is around 0.019.



-- Total population vs vaccinations
-- showing percentage of population that has received at least one covid vaccine

-- Create a query used for CTE or Temp table later
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as totalvaccinations
From PortfolioProject..coviddeaths dea
Join PortfolioProject..covidvaccine vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- using CTE to perform calculation on partition by in previous query

with popvsvac (continent, location, date, population, new_vaccinations, totalvaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as totalvaccinations
From PortfolioProject..coviddeaths dea
Join PortfolioProject..covidvaccine vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

Select *,(totalvaccinations/population)*100 as vaccinationpercentage
From popvsvac
where new_vaccinations is not null


-- or use temp table rather than CTE

Drop Table if exists #Percentpopuvac
Create Table #Percentpopuvac 
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
totalvaccinations numeric
)

Insert into #Percentpopuvac
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as totalvaccinations
From PortfolioProject..coviddeaths dea
Join PortfolioProject..covidvaccine vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


select *,(totalvaccinations/population)*100 as vaccinationpercentage
From #Percentpopuvac
where new_vaccinations is not null



-- creating view to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as totalvaccinations
From PortfolioProject..coviddeaths dea
JOIN PortfolioProject..covidvaccine vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null






