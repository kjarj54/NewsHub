import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _SelectedIndex = 0;

  final List<Widget> _pages = [
    const Home(),
    const News(),
    const Global(),
    const Explore(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _SelectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Laboratorio 5'), centerTitle: true),
      body: _pages[_SelectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: 'News'),
          BottomNavigationBarItem(icon: Icon(Icons.public), label: 'Global'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
        ],
        currentIndex: _SelectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.star, color: Colors.amber),
            title: const Text('Featured Story'),
            subtitle: const Text('Breaking news about technology and innovation'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Quick Access',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: [
            _buildQuickAccessCard(
              context,
              'Technology',
              Icons.computer,
              Colors.blue,
            ),
            _buildQuickAccessCard(
              context,
              'Science',
              Icons.science,
              Colors.green,
            ),
            _buildQuickAccessCard(
              context,
              'Business',
              Icons.business,
              Colors.orange,
            ),
            _buildQuickAccessCard(
              context,
              'Health',
              Icons.health_and_safety,
              Colors.red,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    return Card(
      color: color.withOpacity(0.1),
      child: InkWell(
        onTap: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class News extends StatefulWidget {
  const News({super.key});

  @override
  State<News> createState() => _NewsState();
}

class _NewsState extends State<News> {
  List<NewsArticle> articles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://newsapi.org/v2/everything?q=tech&language=en&sortBy=publishedAt&apiKey=748ae83f1d4c4de3ad84518e6e12297f',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          articles =
              (data['articles'] as List)
                  .map((article) => NewsArticle.fromJson(article))
                  .toList();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching news: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return Card(
          margin: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (article.urlToImage != null)
                CachedNetworkImage(
                  imageUrl: article.urlToImage!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      article.description ?? 'No description available',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Source: ${article.source}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class Global extends StatelessWidget {
  const Global({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Global News Coverage',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Explore news from different regions',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildRegionCard(
          context,
          'Americas',
          ['United States', 'Canada', 'Mexico', 'Brazil'],
          Icons.public_outlined,
          colorScheme.primary,
        ),
        const SizedBox(height: 8),
        _buildRegionCard(
          context,
          'Europe',
          ['United Kingdom', 'France', 'Germany', 'Spain'],
          Icons.euro_outlined,
          colorScheme.secondary,
        ),
        const SizedBox(height: 8),
        _buildRegionCard(
          context,
          'Asia Pacific',
          ['Japan', 'China', 'South Korea', 'India'],
          Icons.brightness_5_outlined,
          colorScheme.tertiary,
        ),
        const SizedBox(height: 8),
        _buildRegionCard(
          context,
          'Middle East & Africa',
          ['UAE', 'Saudi Arabia', 'South Africa', 'Egypt'],
          Icons.mosque_outlined,
          colorScheme.error,
        ),
      ],
    );
  }

  Widget _buildRegionCard(
    BuildContext context,
    String region,
    List<String> countries,
    IconData icon,
    Color color,
  ) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: ExpansionTile(
        leading: Icon(icon, color: color),
        title: Text(
          region,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        children: countries.map((country) => ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 0,
          ),
          leading: const Icon(Icons.location_on_outlined),
          title: Text(country),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {},
        )).toList(),
      ),
    );
  }
}

class Explore extends StatelessWidget {
  const Explore({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SearchBar(
          hintText: 'Search topics...',
          leading: const Icon(Icons.search),
          padding: const MaterialStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 16),
          ),
          onTap: () {},
        ),
        const SizedBox(height: 24),

        ...buildExploreItems(context),
      ],
    );
  }

  List<Widget> buildExploreItems(BuildContext context) {
    final items = [
      {'title': 'Technology', 'icon': Icons.computer, 'count': '24 articles'},
      {'title': 'Science', 'icon': Icons.science, 'count': '18 articles'},
      {'title': 'Health', 'icon': Icons.health_and_safety, 'count': '15 articles'},
      {'title': 'Business', 'icon': Icons.business, 'count': '20 articles'},
      {'title': 'Sports', 'icon': Icons.sports, 'count': '12 articles'},
    ];

    return items.map((item) => Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(item['icon'] as IconData, 
                     color: Theme.of(context).colorScheme.primary),
        title: Text(
          item['title'] as String,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(item['count'] as String),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {},
      ),
    )).toList();
  }
}

class NewsArticle {
  final String title;
  final String? description;
  final String? urlToImage;
  final String source;

  NewsArticle({
    required this.title,
    this.description,
    this.urlToImage,
    required this.source,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? '',
      description: json['description'],
      urlToImage: json['urlToImage'],
      source: json['source']['name'] ?? 'Unknown',
    );
  }
}
