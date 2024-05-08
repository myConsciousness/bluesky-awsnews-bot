enum Feed {
  awsFeed(
    'AWS News Blog',
    'https://aws.amazon.com/blogs/aws/feed',
  ),
  architectureFeed(
    'AWS Architecture Blog',
    'https://aws.amazon.com/blogs/architecture/feed',
  ),
  awsCostManagementFeed(
    'AWS Cost Management',
    'https://aws.amazon.com/blogs/aws-cost-management/feed',
  ),
  apnFeed(
    'AWS Partner Network (APN) Blog',
    'https://aws.amazon.com/blogs/apn/feed',
  ),
  awsMarketplaceFeed(
    'AWS Marketplace',
    'https://aws.amazon.com/blogs/awsmarketplace/feed',
  ),
  bigDataFeed(
    'AWS Big Data Blog',
    'https://aws.amazon.com/blogs/big-data/feed',
  ),
  businessProductivityFeed(
    'Business Productivity',
    'https://aws.amazon.com/blogs/business-productivity/feed',
  ),
  computeFeed(
    'AWS Compute Blog',
    'https://aws.amazon.com/blogs/compute/feed',
  ),
  contactCenterFeed(
    'Contact Center',
    'https://aws.amazon.com/blogs/contact-center/feed',
  ),
  containersFeed(
    'Containers',
    'https://aws.amazon.com/blogs/containers/feed',
  ),
  databaseFeed(
    'AWS Database Blog',
    'https://aws.amazon.com/blogs/database/feed',
  ),
  desktopAndApplicationStreamingFeed(
    'Desktop and Application Streaming',
    'https://aws.amazon.com/blogs/desktop-and-application-streaming/feed',
  ),
  developerFeed(
    'AWS Developer Tools Blog',
    'https://aws.amazon.com/blogs/developer/feed',
  ),
  devopsFeed(
    'AWS DevOps Blog',
    'https://aws.amazon.com/blogs/devops/feed',
  ),
  enterpriseStrategyFeed(
    'AWS Cloud Enterprise Strategy Blog',
    'https://aws.amazon.com/blogs/enterprise-strategy/feed',
  ),
  gameTechFeed(
    'AWS Game Tech Blog',
    'https://aws.amazon.com/blogs/gametech/feed',
  ),
  hpcFeed(
    'AWS HPC Blog',
    'https://aws.amazon.com/blogs/hpc/feed',
  ),
  infrastructureAndAutomationFeed(
    'Infrastructure and Automation',
    'https://aws.amazon.com/blogs/infrastructure-and-automation/feed',
  ),
  industriesFeed(
    'AWS for Industries',
    'https://aws.amazon.com/blogs/industries/feed',
  ),
  iotFeed(
    'The Internet of Things on AWS – Official Blog',
    'https://aws.amazon.com/blogs/iot/feed',
  ),
  machineLearningFeed(
    'AWS Machine Learning Blog',
    'https://aws.amazon.com/blogs/machine-learning/feed',
  ),
  mtFeed(
    'AWS Management and Governance Blog',
    'https://aws.amazon.com/blogs/mt/feed',
  ),
  mediaFeed(
    'AWS Media Blog',
    'https://aws.amazon.com/blogs/media/feed',
  ),
  messagingAndTargetingFeed(
    'AWS Messaging and Targeting Blog',
    'https://aws.amazon.com/blogs/messaging-and-targeting/feed',
  ),
  modernizingWithAwsFeed(
    'Windows on AWS',
    'https://aws.amazon.com/blogs/modernizing-with-aws/feed',
  ),
  mobileFeed(
    'Front-End Web and Mobile',
    'https://aws.amazon.com/blogs/mobile/feed',
  ),
  networkingAndContentDeliveryFeed(
    'Networking and Content Delivery',
    'https://aws.amazon.com/blogs/networking-and-content-delivery/feed',
  ),
  openSourceFeed(
    'AWS Open Source Blog',
    'https://aws.amazon.com/blogs/opensource/feed',
  ),
  publicsectorFeed(
    'AWS Public Sector Blog',
    'https://aws.amazon.com/blogs/publicsector/feed',
  ),
  quantumComputingFeed(
    'AWS Quantum Computing Blog',
    'https://aws.amazon.com/blogs/quantum-computing/feed',
  ),
  roboticsFeed(
    'AWS Robotics Blog',
    'https://aws.amazon.com/blogs/robotics/feed',
  ),
  awsForSapFeed(
    'AWS for SAP',
    'https://aws.amazon.com/blogs/awsforsap/feed',
  ),
  securityFeed(
    'AWS Security Blog',
    'https://aws.amazon.com/blogs/security/feed',
  ),
  startupsFeed(
    'AWS Startups Blog',
    'https://aws.amazon.com/blogs/startups/feed',
  ),
  trainingAndCertificationFeed(
    'AWS Training and Certification Blog',
    'https://aws.amazon.com/blogs/training-and-certification/feed',
  ),
  ;

  String get category => 'Amazon Blog';
  final String title;
  final String uri;

  const Feed(this.title, this.uri);
}
