
"use strict";

class SearchResults
{
	constructor(resultsElement)
	{
		this.results = resultsElement;

		// template element to use for search results, defined in layouts/partials/js_templates.html
		this.template = document.querySelector("template#search-result").content;
	}

	// shows the list
	Show(bOnlyIfPopulated)
	{
		if (bOnlyIfPopulated && this.results.children.length == 0)
		{
			this.Hide();
			return;
		}

		this.results.classList.remove("hidden");
	}

	// hides the list
	Hide()
	{
		if (!this.results.classList.contains("hidden"))
		{
			this.results.classList.add("hidden");
		}
	}

	// clears the result list
	Clear()
	{
		this.results.innerHTML = "";
	}

	// adds a result to the list, using url as the unique id
	AddResult(url, name, description)
	{
		// create new element for search result, populate data, and append to search results
		let element = this.template.cloneNode(true);

		// link
		let a = element.querySelector("a.result");
		a.href = url;

		// title
		let h1 = element.querySelector("h1");
		h1.textContent = name;

		// description
		let p = element.querySelector("p");
		p.textContent = description;

		this.results.appendChild(element);
	}
}

// search bar in the nav used for searching for plugins, only one exists at a time
class SearchBar
{
	constructor(inputElement, resultsElement)
	{
		this.index = null; // built search index
		this.maxResults = 6; // max search results to return
		this.documents = {}; // document contents for search index ref
		this.input = inputElement; // text input element
		this.results = new SearchResults(resultsElement); // search results component

		// fetch search index
		fetch("/all/index.json", {
			method: "get"
		})
		.then(response => response.json())
		.then(response => this.BuildIndex(response));

		// register event listeners
		this.input.addEventListener("focusin", event => this.OnFocused());
		this.input.addEventListener("focusout", event => this.OnUnfocused());
		this.input.addEventListener("input", event => this.OnInputTyped(event.target.value));
	}

	// builds the search index with the given json
	BuildIndex(json)
	{
		let that = this;

		this.index = lunr(function()
		{
			this.ref("url");
			this.field("name");
			this.field("author");
			this.field("schema");
			this.field("description");

			json.forEach(function(document)
			{
				this.add(document);

				let description = document.description.substr(0, 128).trim() + (document.description.length > 128 ? "..." : "");

				that.documents[document.url] = {
					name: document.name,
					schema: document.schema,
					description: description
				}
			}, this);
		});
	}

	OnFocused()
	{
		this.results.Show(true);
	}

	OnUnfocused()
	{
		this.results.Hide();
	}

	// called when the search bar was modified, text is the current text in the search bar
	OnInputTyped(text)
	{
		if (text.length <= 2)
		{
			this.results.Clear();
			this.results.Hide();

			return;
		}

		this.Search(text);
	}

	// called when the search index should be queried
	Search(query)
	{
		this.RenderResults(this.index.search(query));
	}

	// called when a search query has finished
	RenderResults(results)
	{
		this.results.Clear();

		if (results.length > this.maxResults)
		{
			results = results.slice(0, this.maxResults);
		}

		results.forEach((document, i) =>
		{
			let data = this.documents[document.ref];
			this.results.AddResult(document.ref, data.name, data.description);
		});

		this.results.Show(true);
	}
}

// element that belongs to a TabContainer
class Tab
{
	constructor(container, index, header, page)
	{
		this.container = container;
		this.index = index;
		this.header = header;
		this.page = page;

		// register event listeners
		this.header.addEventListener("click", event => this.OnHeaderClicked(index));
	}

	SetActive(bActive)
	{
		// header is the "a" element - we need to set the active class on the header's parent "li" element
		if (bActive)
		{
			this.header.parentElement.classList.add("active");
			this.page.classList.add("active");
		}
		else
		{
			this.header.parentElement.classList.remove("active");
			this.page.classList.remove("active");
		}
	}

	OnHeaderClicked()
	{
		// notify container that we need to switch tabs
		this.container.OnTabClicked(this);
	}
}

// element that holds a tabbed view
class TabContainer
{
	constructor(element)
	{
		this.element = element;
		this.tabs = [];

		const headers = this.element.querySelectorAll("header ul li a");

		headers.forEach(header =>
		{
			const index = header.getAttribute("href").substring(1);
			const page = this.element.querySelector(`.page[data-index="${index}"]`);

			if (!page)
			{
				console.error(`attempted to set up tab "${index}" without corresponding page`);
				return;
			}

			let tab = new Tab(this, index, header, page);
			this.tabs.push(tab);
		});
	}

	OnTabClicked(clickedTab)
	{
		this.tabs.forEach(tab =>
		{
			if (tab == clickedTab)
			{
				tab.SetActive(true);
			}
			else
			{
				tab.SetActive(false);
			}
		});

		history.replaceState(undefined, undefined, "#" + clickedTab.index);
	}

	// sets an active tab by the index
	SetActiveTab(index)
	{
		let bFound = false;

		for (let tab of this.tabs)
		{
			if (tab.index == index)
			{
				tab.SetActive(true);

				bFound = true;
				break;
			}
		}

		// only set other tabs inactive if we found a matching index
		if (bFound)
		{
			this.tabs.forEach(tab =>
			{
				if (tab.index != index)
				{
					tab.SetActive(false);
				}
			});
		}
	}
}

// hero button for downloading a plugin
class DownloadButton
{
	constructor(element)
	{
		this.element = element;
		this.bDownloading = false; // whether or not this button is currently downloading
		this.url = this.element.getAttribute("data-git-download-url"); // download url
		this.text = this.element.querySelector(".text"); // text element this button has

		if (!this.url)
		{
			console.error("could not find url from download button!");
			return;
		}

		if (!this.text)
		{
			console.error("couldn't find text element in download button!");
			return;
		}

		this.element.addEventListener("click", event => this.OnClicked());
	}

	OnClicked()
	{
		if (this.bDownloading === true)
		{
			console.warn("attempted to download plugin while download was already in progress!");
			return;
		}

		this.bDownloading = true;
		this.text.textContent = "Downloading...";

		GitZip.registerCallback((status, message) => this.OnDownloadProgress(status, message));
		GitZip.zipRepo(this.url);
	}

	OnDownloadProgress(status, message)
	{
		console.log("[GitZip " + status + "] " + message);

		if (status == "done")
		{
			this.OnDownloadComplete();
		}
		else if (status == "error")
		{
			this.OnDownloadError();
		}
	}

	OnDownloadComplete()
	{
		this.bDownloading = false;
		this.text.textContent = "Download";
	}

	OnDownloadError()
	{
		this.text.textContent = "Error downloading!";
	}
}

// displays a date relative to now (e.g 10 hours ago, 2 days ago, etc.)
class RelativeDateDisplay
{
	static GetTimeSince(date)
	{
		const seconds = Math.floor((new Date() - date) / 1000);

		var interval = Math.floor(seconds / 31536000);
		if (interval > 1)
		{
			return interval + " years ago";
		}

		interval = Math.floor(seconds / 2592000);
		if (interval > 1)
		{
			return interval + " months ago";
		}

		interval = Math.floor(seconds / 86400);
		if (interval > 1)
		{
			return interval + " days ago";
		}

		interval = Math.floor(seconds / 3600);
		if (interval > 1)
		{
			return interval + " hours ago";
		}

		interval = Math.floor(seconds / 60);
		if (interval > 1)
		{
			return interval + " minutes ago";
		}

		return Math.floor(seconds) + " seconds ago";
	}

	constructor(element)
	{
		this.element = element;
		this.date = new Date(this.element.getAttribute("data-relative-date"));
		this.element.textContent = RelativeDateDisplay.GetTimeSince(this.date);
	}
}

// app singleton
class App
{
	constructor()
	{
		this.searchBar = null;
		this.tabs = [];
		this.downloadButtons = [];
		this.relativeDates = [];

		// setup search bar
		const searchBar = document.querySelector("#search input");
		const searchResults = document.querySelector("#search .results")

		if (searchBar && searchResults)
		{
			this.searchBar = new SearchBar(searchBar, searchResults);
		}

		// setup tab containers
		const tabElements = document.querySelectorAll(".tabs");

		tabElements.forEach(element =>
		{
			let container = new TabContainer(element);
			this.tabs.push(container);
		});

		// navigate to anchor in url if there's only one TabContainer
		if (this.tabs.length == 1 && location.hash.length > 0)
		{
			const container = this.tabs[0];
			const index = location.hash.substring(1);

			container.SetActiveTab(index);
		}

		// setup download button handlers
		const downloadButtons = document.querySelectorAll("a.download[data-git-download-url]");

		downloadButtons.forEach(element =>
		{
			let button = new DownloadButton(element);
			this.downloadButtons.push(button);
		});

		// replace text for relative dates
		const dateElements = document.querySelectorAll("[data-relative-date]");

		dateElements.forEach(element =>
		{
			let relativeDate = new RelativeDateDisplay(element);
			this.relativeDates.push(relativeDate);
		});
	}
}

document.addEventListener("DOMContentLoaded", function(event)
{
	window.app = new App();
});
