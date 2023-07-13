#Creating Database

create database Projects;

#Import csv file into databases

load data infile '\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Covid Data\\CovidDeaths.csv'
into table coviddeaths
fields terminated by ','
enclosed by '"'
lines terminated by '\r\n' ignore 1 rows;

#Import csv file into databases

load data infile '\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Covid Data\\CovidVaccinations.csv'
into table covidvaccinations
fields terminated by ','
enclosed by '"'
lines terminated by '\r\n' ignore 1 rows;


select * from coviddeaths
order by 3,4;

select * from covidvaccinations
order by 3,4;

# select the data we going to be using
SELECT 
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM
    coviddeaths
ORDER BY 1 , 2;

# looking at Total cases vs total death
-- show likelihood of dying if you contract covid in your  country

SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths / total_cases) * 100 AS deathsPercentage
FROM
    coviddeaths
WHERE
    location LIKE '%india%'
ORDER BY 1 , 2;
    
-- Loking at total cases vs total Population
-- shows what percentage of population got covid
SELECT 
    location,
    date,
    population,
    total_cases,
    (total_cases / population) * 100 as PercentPopulationInfected
FROM
    coviddeaths
WHERE
    location = 'India'
ORDER BY 1 , 2;

SELECT 
    location,
    population,
    MAX(total_cases) as HighestInfected,
    MAX(total_cases / population) * 100 AS PercentPopulationInfected
FROM
    coviddeaths where continent is not null
GROUP BY location , population
ORDER BY PercentPopulationInfected DESC;


-- Let's break things down by continent

select location, max(total_deaths) as totalDeathCount from coviddeaths where continent is null group by location order by totalDeathCount;

-- Global Numbers

select  sum(new_cases) as totalCases, sum(new_deaths) as totalDeaths, ((sum(new_deaths))/(sum(new_cases)))*100 as DeathPercent from coviddeaths group by date order by 1,2;



-- Lookin at Population vs vaccinations

SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.date , dea.location) as RollingPeopleVaccinated
FROM
    coviddeaths dea
        JOIN
    covidvaccinations vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
ORDER BY 2 , 3;


-- USE CTE 
with PopvsVac  as (SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.date , dea.location) as RollingPeopleVaccinated
FROM
    coviddeaths dea
        JOIN
    covidvaccinations vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE dea.continent IS NOT NULL)
select * , (RollingPeopleVaccinated/population)*100 as RPVPecent from PopvsVac ;



-- Temp Table
drop table if exists PercentPopulationVaccinated;
create temporary table PercentPopulationVaccinated (continent varchar(255), location varchar(255), date date, new_vaccinations int, RollingPeopleVaccinated int, RPVPecent int); 
insert into PercentPopulationVaccinated  SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.date , dea.location) as RollingPeopleVaccinated
FROM
    coviddeaths dea
        JOIN
    covidvaccinations vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL;
select * from PercentPopulationVaccinated ;



-- Creating Views

create view PercentPopulationVaccinated as  SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.date , dea.location) as RollingPeopleVaccinated
FROM
    coviddeaths dea
        JOIN
    covidvaccinations vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL;
    
    
