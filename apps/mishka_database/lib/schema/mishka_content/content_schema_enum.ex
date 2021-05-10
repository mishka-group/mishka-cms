import EctoEnum
defenum ContentStatusEnum, inactive: 0, active: 1, archived: 2, soft_delete: 3
defenum ContentPriorityEnum, none: 0, low: 1, medium: 2, high: 3, featured: 4
defenum ContentRobotsEnum, IndexFollow: 0, IndexNoFollow: 1, NoIndexFollow: 2, NoIndexNoFollow: 3
defenum CategoryVisibility, show: 0, invisibel: 1, test_show: 2, test_invisibel: 3
defenum CommentSection, blog_post: 0
defenum SubscriptionSection, blog_post: 0
defenum BlogLinkType, bottem: 0, inside: 1, featured: 2
defenum ActivitiesStatusEnum, error: 0, info: 1, warning: 2, report: 3
defenum ActivitiesTypeEnum, section: 0, email: 1, internal_api: 2, external_api: 3
defenum ActivitiesSection, blog_post: 0, blog_category: 1, comment: 2, tag: 3, other: 4
defenum ActivitiesAction, create: 0, edit: 1, delete: 2, destroy: 3, read: 4, send_request: 5, receive_request: 6, other: 7
defenum BookmarkSection, blog_post: 0
defenum NotifSection, blog_post: 0, blog_category: 1, blog_comment: 3, admin: 4, user_only: 5, other: 6
